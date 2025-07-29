//
//  P2PHostSelector.swift

import Foundation
import MultipeerConnectivity

private enum HostEvent: Codable {
    case requestHost
    case announceHost(hostStartTime: TimeInterval)
}

private struct Host {
    let peer: Peer
    let startTime: TimeInterval

    var isMe: Bool {
        peer.isMe
    }
}

/// Decide which connected peer is the host.
/// The last Peer to call `makeMeHost()` becomes the host of all connected Peers.
class P2PHostSelector {
    var onHostUpdateHandler: ((_ host: Peer?) -> Void)?

    var host: Peer? {
        _lock.lock(); defer { _lock.unlock() }
        return _host?.peer
    }

    private var _lock = NSLock()
    private var _host: Host?
    private let _hostEventService = P2PEventService<HostEvent>("P2PKit.P2PHostSelector")

    private func autoElectHostIfNeeded() {
        guard _host == nil else { return }
        let peers = P2PNetwork.connectedPeers + [P2PNetwork.myPeer]
        guard peers.count == 2 else { return }
        let candidate = peers.min(by: { $0.id < $1.id })!
        prettyPrint("Auto-elected host: \(candidate.displayName)")
        if candidate.isMe { makeMeHost() }
    }

    init() {
        P2PNetwork.addPeerDelegate(self)
        setupHostEventService()
        autoElectHostIfNeeded() // 🚀 최초 평가
    }

    deinit {
        P2PNetwork.removePeerDelegate(self)
    }

    func makeMeHost() {
        setHost(Host(peer: P2PNetwork.myPeer,
                     startTime: Date().timeIntervalSince1970))
    }

    private func setHost(_ host: Host?) {
        _lock.lock()
        _host = host
        _lock.unlock()

        prettyPrint("Setting new Host to [\(host?.peer.displayName ?? "nil")]")
        onHostUpdateHandler?(host?.peer)
        if let host = host, host.isMe {
            announceHost(host)
        }
    }

    // MARK: Host Event Service

    private func setupHostEventService() {
        _hostEventService.onReceive {
            [weak self] _, hostAction, _, sender in
            guard let self = self else { return }
            switch hostAction {
            case .requestHost:
                if let host = _host, host.isMe {
                    announceHost(host, to: [sender])
                }
            case let .announceHost(hostStartTime):
                receiveHostAnnouncement(from: sender, senderHostStartTime: hostStartTime)
            }
        }
    }

    private func receiveHostAnnouncement(from sender: MCPeerID, senderHostStartTime: TimeInterval) {
        if let hostPeer = P2PNetwork.connectedPeers.first(where: { $0.peerID == sender }) {
            _lock.lock()
            if let host = _host, host.isMe, host.startTime > senderHostStartTime {
                _lock.unlock()
                announceHost(host, to: [])
            } else {
                _lock.unlock()
                setHost(Host(peer: hostPeer, startTime: senderHostStartTime))
            }
        } else {
            prettyPrint(level: .error, "Received host announcement, but I'm not connected to host.")
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
                self?.requestHost(from: sender)
            }.fire()
            setHost(nil)
        }
    }

    private func announceHost(_ host: Host, to peers: [MCPeerID] = []) {
        _hostEventService.send(payload: .announceHost(hostStartTime: host.startTime), to: peers, reliable: true)
    }

    private func requestHost(from sender: MCPeerID) {
        _hostEventService.send(payload: .requestHost, to: [sender], reliable: true)
    }
}

extension P2PHostSelector: P2PNetworkPeerDelegate {
    func p2pNetwork(didUpdate peer: Peer) {
        autoElectHostIfNeeded() // 연결 변화마다 재평가
        _lock.lock()
        if let host = _host {
            _lock.unlock()
            let connectedPeers = P2PNetwork.connectedPeers
            if host.isMe {
                if connectedPeers.contains(peer) {
                    // Announce to newly connected Peers that I am host
                    announceHost(host, to: [peer.peerID])
                }
            } else if !connectedPeers.contains(host.peer) {
                // I've lost connection to existing host
                setHost(nil)
            }
        } else {
            _lock.unlock()
        }
    }

    func p2pNetwork(didUpdateHost _: Peer?) {
        // Intentionally empty
    }
}
