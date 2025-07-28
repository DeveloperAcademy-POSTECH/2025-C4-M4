//
//  P2PSession.swift
//  P2PKitExample
//
//  Created by Paige Sun on 5/2/24.
//

import MultipeerConnectivity

// MARK: - P2PSession

protocol P2PSessionDelegate: AnyObject {
    func p2pSession(_ session: P2PSession, didUpdate peer: Peer)
    func p2pSession(_ session: P2PSession, didReceive data: Data, dataAsJson json: [String: Any]?, from peerID: MCPeerID)
}

class P2PSession: NSObject {
    weak var delegate: P2PSessionDelegate?

    let myPeer: Peer
    private var myDiscoveryInfo: DiscoveryInfo

    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser

    private var peersLock = NSLock()
    private var foundPeers = Set<MCPeerID>() // protected with peersLock
    private var discoveryInfos = [MCPeerID: DiscoveryInfo]() // protected with peersLock
    private var sessionStates = [MCPeerID: MCSessionState]() // protected with peersLock
    private var invitesHistory = [MCPeerID: InviteHistory]() // protected with peersLock
    private var loopbackTestTimers = [MCPeerID: Timer]() // protected with peersLock

    var connectedPeers: [Peer] {
        peersLock.lock(); defer { peersLock.unlock() }
        let peerIDs = session.connectedPeers.filter {
            foundPeers.contains($0) && sessionStates[$0] == .connected
        }
        prettyPrint(level: .debug, "connectedPeers: \(peerIDs)")
        return peerIDs.compactMap { peer(for: $0) }
    }

    // Debug only, use connectedPeers instead.
    var allPeers: [Peer] {
        peersLock.lock(); defer { peersLock.unlock() }
        let peerIDs = session.connectedPeers.filter {
            foundPeers.contains($0)
        }
        prettyPrint(level: .debug, "all peers: \(peerIDs)")
        return peerIDs.compactMap { peer(for: $0) }
    }

    // Callers need to protect this with peersLock
    private func peer(for peerID: MCPeerID) -> Peer? {
        guard let discoverID = discoveryInfos[peerID]?.discoveryId else { return nil }
        return Peer(peerID, id: discoverID)
    }

    let groupID = P2PNetwork.currentGroupID ?? "initial"
    let groupSize = P2PNetwork.maxConnectedPeers

    init(myPeer: Peer) {
        self.myPeer = myPeer
        myDiscoveryInfo = DiscoveryInfo(
            discoveryId: myPeer.id,
            groupID: groupID,
            groupSize: groupSize
        )
        discoveryInfos[myPeer.peerID] = myDiscoveryInfo
        let myPeerID = myPeer.peerID
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                                               discoveryInfo: ["discoveryId": "\(myDiscoveryInfo.discoveryId)",
                                                               "groupID": "\(myDiscoveryInfo.groupID)",
                                                               "groupSize": "\(myDiscoveryInfo.groupSize)"],
                                               serviceType: P2PConstants.networkChannelName)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: P2PConstants.networkChannelName)

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func start() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        delegate?.p2pSession(self, didUpdate: myPeer)
    }

    // MARK: - 다시 검색을 위해 구현한 코드 입니다. - 추후 변경가능합니다.

    deinit {
        disconnect()
    }

    func disconnect() {
        prettyPrint("disconnect")

        session.disconnect()
        session.delegate = nil

        advertiser.stopAdvertisingPeer()
        advertiser.delegate = nil

        browser.stopBrowsingForPeers()
        browser.delegate = nil
    }

    func disconnectPeer(_ peerID: MCPeerID) {
        prettyPrint("disconnecting peer: \(peerID.displayName)")

//        browser.cancelConnectPeer(peerID)
        session.cancelConnectPeer(peerID)
    }

    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }

    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }

    func connectionState(for peer: MCPeerID) -> MCSessionState? {
        peersLock.lock(); defer { peersLock.unlock() }
        return sessionStates[peer]
    }

    func makeBrowserViewController() -> MCBrowserViewController {
        MCBrowserViewController(browser: browser, session: session)
    }

    // MARK: - Sending

    func send(_ encodable: Encodable, to peers: [MCPeerID] = [], reliable: Bool) {
        do {
            let data = try JSONEncoder().encode(encodable)
            send(data: data, to: peers, reliable: reliable)
        } catch {
            prettyPrint(level: .error, "Could not encode: \(error.localizedDescription)")
        }
    }

    // Reliable maintains order and doesn't drop data but is slower.
    func send(data: Data, to peers: [MCPeerID] = [], reliable: Bool) {
        let sendToPeers = peers.isEmpty ? session.connectedPeers : peers
        guard !sendToPeers.isEmpty else {
            return
        }

        do {
            try session.send(data, toPeers: sendToPeers, with: reliable ? .reliable : .unreliable)
        } catch {
            prettyPrint(level: .error, "error sending data to peers: \(error.localizedDescription)")
        }
    }

    // MARK: - Loopback Test

    // Test whether a connection is still alive.

    // Call with within a peersLock.
    private func startLoopbackTest(_ peerID: MCPeerID) {
        prettyPrint("Sending Ping to \(peerID.displayName)")
        send(["ping": ""], to: [peerID], reliable: true)

        // If A pings B but B doesn't pong back, B disconnected or unable to respond. In that case A tells B to reset.
        loopbackTestTimers[peerID] = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] _ in
            prettyPrint("Did not receive pong from \(peerID.displayName). Asking it to reset.")
            self?.send(["pongNotReceived": ""], to: [peerID], reliable: true)
        })
    }

    private func receiveLoopbackTest(_: MCSession, didReceive json: [String: Any], fromPeer peerID: MCPeerID) -> Bool {
        if json["ping"] as? String == "" {
            prettyPrint("Received ping from \(peerID.displayName). Sending Pong.")
            send(["pong": ""], to: [peerID], reliable: true)
            return true
        } else if json["pong"] as? String == "" {
            prettyPrint("Received Pong from \(peerID.displayName)")
            peersLock.lock()
            if sessionStates[peerID] == nil {
                sessionStates[peerID] = .connected
            }
            loopbackTestTimers[peerID]?.invalidate()
            loopbackTestTimers[peerID] = nil
            let peer = peer(for: peerID)
            peersLock.unlock()

            if let peer = peer {
                delegate?.p2pSession(self, didUpdate: peer)
            }
            return true
        } else if json["pongNotReceived"] as? String == "" {
            prettyPrint("Resetting because [\(peerID.displayName)] sent ping to me but didn't receive a pong back.")
            P2PNetwork.resetSession()
        }
        return false
    }
}

// MARK: - MCSessionDelegate

extension P2PSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        prettyPrint("Session state of [\(peerID.displayName)] changed to [\(state)]")
        print("🔄 [P2PSession] Peer '\(peerID.displayName)' didChange state to '\(state)'")

        peersLock.lock()
        sessionStates[peerID] = state

        switch state {
        case .connected:
            foundPeers.insert(peerID)
        case .connecting:
            break
        case .notConnected:
            invitePeerIfNeeded(peerID)
        default:
            fatalError(#function + " - Unexpected multipeer connectivity state.")
        }

        // 세션에 참여한 사람이 maxConnectedPeers명을 초과하면, 초과하는 참여한 사람 퇴출됨
        if session.connectedPeers.count > P2PNetwork.maxConnectedPeers {
            let excessPeers = session.connectedPeers.filter { peerID in
                !connectedPeers.map(\.peerID).contains(peerID)
            }
            for peer in excessPeers {
                prettyPrint(level: .error, "Exceeding max peers. Rejecting [\(peer.displayName)]")
                session.cancelConnectPeer(peer)
            }
        }

        let peer = peer(for: peerID)
        peersLock.unlock()

        if let peer = peer {
            delegate?.p2pSession(self, didUpdate: peer)
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let json = json, receiveLoopbackTest(session, didReceive: json, fromPeer: peerID) {
            return
        }

        // Recieving data is from different threads, so don't get Peer.Identifier here.
        delegate?.p2pSession(self, didReceive: data, dataAsJson: json, from: peerID)
    }

    func session(_: MCSession, didReceive _: InputStream, withName _: String, fromPeer _: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }

    func session(_: MCSession, didStartReceivingResourceWithName _: String, fromPeer _: MCPeerID, with _: Progress) {
        fatalError("This service does not send/receive resources.")
    }

    func session(_: MCSession, didFinishReceivingResourceWithName _: String, fromPeer _: MCPeerID, at _: URL?, withError _: Error?) {
        fatalError("This service does not send/receive resources.")
    }

    func session(_: MCSession, didReceiveCertificate _: [Any]?, fromPeer _: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

// MARK: - Browser Delegate

extension P2PSession: MCNearbyServiceBrowserDelegate {
    func browser(_: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("🔍 [P2PSession] Found peer: '\(peerID.displayName)', discoveryInfo: \(info ?? [:])")
        if let discoveryId = info?["discoveryId"], discoveryId != myDiscoveryInfo.discoveryId {
            prettyPrint("Found Peer: [\(peerID)], with id: [\(discoveryId)]")

            peersLock.lock()
            foundPeers.insert(peerID)

            // Each device has one DiscoveryId. When a new MCPeerID is found, cleanly remove older MCPeerIDs from the same device.
            for (otherPeerId, otherDiscoveryInfo) in discoveryInfos {
                if otherDiscoveryInfo.discoveryId == discoveryId, otherPeerId != peerID {
                    foundPeers.remove(otherPeerId)
                    discoveryInfos[otherPeerId] = nil
                    sessionStates[otherPeerId] = nil
                    invitesHistory[otherPeerId] = nil
                }
            }
            let groupID = info?["groupID"] ?? "unknown"
            let groupSize = Int(info?["groupSize"] ?? "0") ?? 0
            discoveryInfos[peerID] = DiscoveryInfo(discoveryId: discoveryId, groupID: groupID, groupSize: groupSize)
            if sessionStates[peerID] == nil, session.connectedPeers.contains(peerID) {
                startLoopbackTest(peerID)
            }

            invitePeerIfNeeded(peerID)
            let peer = peer(for: peerID)
            peersLock.unlock()

            if let peer = peer {
                delegate?.p2pSession(self, didUpdate: peer)
            }
        }
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("❗️ [P2PSession] Lost peer: '\(peerID.displayName)'")
        prettyPrint("Lost peer: [\(peerID.displayName)]")

        peersLock.lock()
        foundPeers.remove(peerID)

        // When a peer enters background, session.connectedPeers still contains that peer.
        // Setting this to nil ensures we make a loopback test to test the connection.
        sessionStates[peerID] = nil
        let peer = peer(for: peerID)
        peersLock.unlock()

        if let peer = peer {
            delegate?.p2pSession(self, didUpdate: peer)
        }
    }
}

// MARK: - Advertiser Delegate

extension P2PSession: MCNearbyServiceAdvertiserDelegate {
    // 누군가 나에게 연결 요청을 보냈을 때 호출됨
    func advertiser(_: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext _: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let totalAttemptingPeers = session.connectedPeers.count +
            sessionStates.values.filter { $0 == .connecting }.count

        if isNotConnected(peerID), totalAttemptingPeers < P2PNetwork.maxConnectedPeers {
            invitationHandler(true, session)
        } else {
            prettyPrint(level: .info, "Rejecting invitation from \(peerID.displayName). Already full.")
            invitationHandler(false, nil)
        }
    }

    func advertiser(_: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        prettyPrint(level: .error, "Error: \(error.localizedDescription)")
    }
}

// MARK: - Private - Invite Peers

extension P2PSession {
    // Call this from inside a peerLock()
    private func invitePeerIfNeeded(_ peerID: MCPeerID) {
        func invitePeer(attempt: Int) {
            prettyPrint("Inviting peer: [\(peerID.displayName)]. Attempt \(attempt)")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: inviteTimeout)
            invitesHistory[peerID] = InviteHistory(attempt: attempt, nextInviteAfter: Date().addingTimeInterval(retryWaitTime))
        }

        // Between any pair of devices, only one invites.
        guard let otherDiscoverID = discoveryInfos[peerID]?.discoveryId,
              myDiscoveryInfo.discoveryId < otherDiscoverID, isNotConnected(peerID)
        else {
            return
        }

        guard session.connectedPeers.count < P2PNetwork.maxConnectedPeers
        // 이미 한 명 연결됨
        else {
            return
        }

        let retryWaitTime: TimeInterval = 3 // time to wait before retrying invite
        let maxRetries = 3
        let inviteTimeout: TimeInterval = 8 // time before retrying times out

        if let prevInvite = invitesHistory[peerID] {
            if prevInvite.nextInviteAfter.timeIntervalSinceNow < -(inviteTimeout + 3) {
                // Waited long enough that we can restart attempt from 1.
                invitePeer(attempt: 1)

            } else if prevInvite.nextInviteAfter.timeIntervalSinceNow < 0 {
                // Waited long enough to do the next invite attempt.
                if prevInvite.attempt < maxRetries {
                    invitePeer(attempt: prevInvite.attempt + 1)
                } else {
                    prettyPrint(level: .error, "Max \(maxRetries) invite attempts reached for [\(peerID.displayName)].")
                    P2PNetwork.resetSession()
                }

            } else {
                if !prevInvite.nextInviteScheduled {
                    // Haven't waited long enough for next invite, so schedule the next invite.
                    prettyPrint("Inviting peer later: [\(peerID.displayName)] with attempt \(prevInvite.attempt + 1)")

                    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + retryWaitTime + 0.1) { [weak self] in
                        guard let self = self else { return }
                        self.peersLock.lock()
                        self.invitesHistory[peerID]?.nextInviteScheduled = false
                        self.invitePeerIfNeeded(peerID)
                        self.peersLock.unlock()
                    }
                    invitesHistory[peerID]?.nextInviteScheduled = true
                } else {
                    prettyPrint("No need to invite peer [\(peerID.displayName)]. Next invite is already scheduled.")
                }
            }
        } else {
            invitePeer(attempt: 1)
        }
    }

    private func isNotConnected(_ peerID: MCPeerID) -> Bool {
        !session.connectedPeers.contains(peerID)
            && sessionStates[peerID] != .connecting
            && sessionStates[peerID] != .connected
    }
}

extension P2PSession {
    func startAdvertisingAndBrowsing(with discoveryInfo: [String: String]) {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeer.peerID,
            discoveryInfo: discoveryInfo,
            serviceType: P2PConstants.networkChannelName
        )
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(
            peer: myPeer.peerID,
            serviceType: P2PConstants.networkChannelName
        )
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
}

private struct InviteHistory {
    let attempt: Int
    let nextInviteAfter: Date
    var nextInviteScheduled: Bool = false
}

// MARK: - Private

private struct DiscoveryInfo {
    let discoveryId: Peer.Identifier
    let groupID: String
    let groupSize: Int
}
