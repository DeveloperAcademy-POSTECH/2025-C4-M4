//
//  P2PNetwork.swift
//  P2PKitExample
//
//  Created by Paige Sun on 5/2/24.
//

import Combine
import CryptoKit
import Foundation
import MultipeerConnectivity
import SwiftUI

public enum P2PConstants {
    public static var networkChannelName = "my-p2p-2p"
    public static func setGamePlayerCount(_ count: Int) {
        networkChannelName = "my-p2p-\(count)p"
    }

    public static var loggerEnabled = true

    enum UserDefaultsKeys {
        static let myMCPeerID = "com.P2PKit.MyMCPeerIDKey"
        static let myPeerID = "com.P2PKit.MyPeerIDKey"
    }
}

public protocol P2PNetworkPeerDelegate: AnyObject {
    func p2pNetwork(didUpdate peer: Peer) // 어떤 peer의 연결상태가 변경될때 호출
    func p2pNetwork(didUpdateHost host: Peer?) // host가 바뀔 때 호출
}

public struct EventInfo: Codable {
    public let senderEntityID: String?
    public let sendTime: Double
}

public enum P2PNetwork {
    public static var maxConnectedPeers: Int = 2 // 기본 플레이 인원은 2명
    public static var currentTurnPlayerID = P2PSyncedObservable<Peer.Identifier>(name: "currentTurnPlayerID", initial: P2PNetwork.myPeer.id)

    private static var session = P2PSession(myPeer: Peer.getMyPeer())
    private static let sessionListener = P2PNetworkSessionListener()
    private static let hostSelector: P2PHostSelector = {
        let hostSelector = P2PHostSelector()
        hostSelector.onHostUpdateHandler = { host in
            sessionListener.onHostUpdate(host: host)
        }
        return hostSelector
    }()

    // 새로운 변수를 추가함 - 새로운 현재 그룹 ID을 만든다.
    public static var currentGroupID: String?

    // MARK: - Public P2PHostSelector

    /// 현재 디바이스가 P2P 호스트인지 여부
    public static var isHost: Bool {
        host?.id == myPeer.id
    }

    public static var host: Peer? {
        hostSelector.host
    }

    public static func makeMeHost() {
        hostSelector.makeMeHost()
    }

    // MARK: - Public P2PSession Getters

    public static var myPeer: Peer {
        session.myPeer
    }

    /// Map of peerID strings to their reported group lists for cross-verification
    private static var groupVerificationMap = [String: [String]]()
    // Keep a strong reference to the DataHandler so it is not deallocated
    private static var groupVerificationHandler: DataHandler?

    public static func setupGroupVerificationListener() {
        groupVerificationHandler = onReceiveData(eventName: "GroupVerificationMessage") { _, json, peerID in
            guard let receivedIDs = json?["peerIDs"] as? [String] else {
                prettyPrint("⚠️ 잘못된 GroupVerificationMessage 수신")
                return
            }
            print("[P2PNetwork] 📨 GroupVerificationMessage 수신 from \(peerID.displayName)")
            // 1. 메시지 저장
            let sortedIDs = receivedIDs.sorted()
            groupVerificationMap[peerID.displayName] = sortedIDs
            // 2. 내 own ID 리스트 저장
            let myGroupIDs = ([myPeer] + connectedPeers).map(\.id).sorted()
            groupVerificationMap[myPeer.id] = myGroupIDs
            prettyPrint("🔄 교차 검증 메시지 수신 from \(peerID.displayName): \(sortedIDs)")

            // 기대 참가자 수 (본인 포함)
            let expectedCount = maxConnectedPeers + 1
            if groupVerificationMap.count == expectedCount {
                // 3. 교차 검증 수행: 모든 리스트의 교집합 계산
                var intersectionSet = Set(myGroupIDs)
                for ids in groupVerificationMap.values {
                    intersectionSet.formIntersection(Set(ids))
                }
                prettyPrint("🔍 교차 검증 결과: \(intersectionSet)")

                // 4. 불일치 피어 연결 해제
                for peer in connectedPeers {
                    if !intersectionSet.contains(peer.id) {
                        prettyPrint("❌ 교차 검증 실패. \(peer.displayName) 연결 해제")
                        session.disconnectPeer(peer.peerID)
                    }
                }
                // 5. 맵 초기화
                groupVerificationMap.removeAll()

                // 6. 검증 성공 시 세션 고정 또는 실패 시 재탐색
                if intersectionSet.count == expectedCount {
                    prettyPrint("🔒 교차 검증 완료. 해당 그룹만 고정")
                    // 그룹에 포함된 Peer 객체 배열 생성 (나 자신 포함)
                    let groupPeers = ([myPeer] + connectedPeers).filter { intersectionSet.contains($0.id) }
                    // 해당 그룹만 잠금 및 재광고
                    finalizeGroupLockIfValid(peers: groupPeers)
                    // 알림 퍼블리셔 방출
                    groupDidLockPublisher.send()
                } else {
                    // 실패 시 초기 탐색 재시작
                    restartInitialDiscovery()
                }
            }
        }
    }

    private static func restartInitialDiscovery() {
        let discoveryInfo = [
            "discoveryId": myPeer.id,
            "groupSize": "\(maxConnectedPeers)",
        ]

        session.stopAdvertising()
        session.stopBrowsing()
        session.startAdvertisingAndBrowsing(with: discoveryInfo)

        prettyPrint("♻️ 초기 광고/브라우징 재시작")
        groupDidResetPublisher.send() // ← 여기 추가
    }

    // 피어 발견 시 groupID 기준으로 무시
    public static func shouldAcceptDiscovery(info: [String: String]?) -> Bool {
        // ✅ 그룹 확정 이후 → groupID 기준 필터
        if let expectedGroupID = currentGroupID,
           let remoteGroupID = info?["groupID"]
        {
            return remoteGroupID == expectedGroupID
        }

        // ✅ 초기 탐색 단계 → groupSize 기준 필터
        if let remoteGroupSizeStr = info?["groupSize"],
           let remoteGroupSize = Int(remoteGroupSizeStr)
        {
            return remoteGroupSize == maxConnectedPeers
        }

        // ❌ 정보 없음 → 연결 거부
        return false
    }

    public static var groupDidLockPublisher = PassthroughSubject<Void, Never>()

    public static var groupDidResetPublisher = PassthroughSubject<Void, Never>()
    public static var isSessionLocked: Bool = false

    private static func makeGroupID() -> String {
        UUID().uuidString.prefix(6).uppercased()
    }

    public static func lockSession() {
        guard !isSessionLocked else { return } // 중복 방지
        isSessionLocked = true
        currentGroupID = makeGroupID()

        session.stopAdvertising()
        session.stopBrowsing()

        let newDiscoveryInfo = [
            "discoveryId": myPeer.id,
            "groupID": currentGroupID!,
        ]
        session.startAdvertisingAndBrowsing(with: newDiscoveryInfo)

        print("🔐 그룹 고정됨, 광고/탐색 재시작")

        groupDidLockPublisher.send()
    }

    public static func finalizeGroupLockIfValid(peers: [Peer]) {
        // Mark session locked so only groupID is accepted in shouldAcceptDiscovery
        isSessionLocked = true

        let groupID = generateGroupID(from: peers)
        currentGroupID = groupID

        // Stop any existing advertise/browse
        session.stopAdvertising()
        session.stopBrowsing()

        // Start advertise/browse with groupID only
        let newDiscoveryInfo = [
            "discoveryId": myPeer.id,
            "groupID": groupID,
        ]
        session.startAdvertisingAndBrowsing(with: newDiscoveryInfo)

        prettyPrint("🔐 그룹 고정. groupID 기반 광고 시작: \(groupID)")
    }

    private static func generateGroupID(from peers: [Peer]) -> String {
        let allIDs = ([myPeer] + peers).map(\.id).sorted()
        let joined = allIDs.joined(separator: "-")
        return joined.sha256().prefix(8).description
    }

//    private static func lockSession() {
//        session.stopAdvertising()
//        session.stopBrowsing()
//    }

    // Connected Peers, not including self
    public static var connectedPeers: [Peer] {
        soloMode ? soloModePeers : session.connectedPeers
    }

    // Debug only, use connectedPeers instead.
    public static var allPeers: [Peer] {
        session.allPeers
    }

    // When true, fake connectedPeers, and disallow sending and receiving.
    public static var soloMode = false
    private static var soloModePeers = [Peer(MCPeerID(displayName: "Player 1"), id: "Player 1"),
                                        Peer(MCPeerID(displayName: "Player 2"), id: "Player 2")]

    // MARK: - Public P2PSession Management

    public static func start() {
        if session.delegate == nil {
            P2PNetwork.hostSelector
            session.delegate = sessionListener
            session.start()
        }

        let initialDiscoveryInfo = [
            "discoveryId": myPeer.id,
            "groupSize": "\(maxConnectedPeers)",
        ]

        session.startAdvertisingAndBrowsing(with: initialDiscoveryInfo)

        //        if currentTurnPlayerName.value.isEmpty {
        //            // Randomly assign the first turn to one of the peers including self
        //            let candidates = [myPeer] + connectedPeers
        //            if let firstPlayer = candidates.randomElement() {
        //                currentTurnPlayerName.value = firstPlayer.displayName
        //            }
        //        }
    }

    public static func sendGroupVerificationMessage() {
        let allPeerIDs = ([myPeer] + connectedPeers).map(\.id).sorted()
        let envelope: [String: Any] = [
            "eventName": "GroupVerificationMessage",
            "peerIDs": allPeerIDs,
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: envelope) else {
            print("❌ Failed to serialize GroupVerificationMessage envelope")
            return
        }
        // Convert Peer objects to MCPeerID and send
        let targetPeers = connectedPeers.map(\.peerID)
        sendData(data, to: targetPeers, reliable: true)
    }

    public static func connectionState(for peer: MCPeerID) -> MCSessionState? {
        session.connectionState(for: peer)
    }

    public static func outSession(displayName: String? = nil) {
        prettyPrint(level: .error, "♻️ Quitting Session!")
        let oldSession = session
        oldSession.disconnect()

        let newPeerId = MCPeerID(displayName: displayName ?? oldSession.myPeer.displayName)
        let myPeer = Peer.resetMyPeer(with: newPeerId)
        session = P2PSession(myPeer: myPeer)
        session.delegate = sessionListener
    }

    public static func resetSession(displayName: String? = nil) {
        prettyPrint(level: .error, "♻️ Resetting Session!")
        let oldSession = session
        oldSession.disconnect()

        let newPeerId = MCPeerID(displayName: displayName ?? oldSession.myPeer.displayName)
        let myPeer = Peer.resetMyPeer(with: newPeerId)
        session = P2PSession(myPeer: myPeer)
        session.delegate = sessionListener

        let discoveryInfo = currentGroupID == nil
            ? ["discoveryId": myPeer.id, "groupSize": "\(maxConnectedPeers)"]
            : ["discoveryId": myPeer.id, "groupID": currentGroupID!]

        session.startAdvertisingAndBrowsing(with: discoveryInfo)
    }

    public static func makeBrowserViewController() -> MCBrowserViewController {
        session.makeBrowserViewController()
    }

    // MARK: - Peer Delegates

    public static func addPeerDelegate(_ delegate: P2PNetworkPeerDelegate) {
        sessionListener.addPeerDelegate(delegate)
    }

    public static func removePeerDelegate(_ delegate: P2PNetworkPeerDelegate) {
        sessionListener.removePeerDelegate(delegate)
    }

    public static func removeAllDelegates() {
        sessionListener.removeAllDelegates()
    }

    // MARK: - Internal - Send and Receive Events

    static func send(_ encodable: Encodable, to peers: [MCPeerID] = [], reliable: Bool) {
        guard !soloMode else { return }
        session.send(encodable, to: peers, reliable: reliable)
    }

    static func sendData(_ data: Data, to peers: [MCPeerID] = [], reliable: Bool) {
        guard !soloMode else { return }
        session.send(data: data, to: peers, reliable: reliable)
    }

    static func onReceiveData(eventName: String, _ callback: @escaping DataHandler.Callback) -> DataHandler {
        sessionListener.onReceiveData(eventName: eventName, callback)
    }
}

class DataHandler {
    typealias Callback = (_ data: Data, _ dataAsJson: [String: Any]?, _ fromPeerID: MCPeerID) -> Void

    var callback: Callback

    init(_ callback: @escaping Callback) {
        self.callback = callback
    }
}

// MARK: - Private

private class P2PNetworkSessionListener {
    private var _peerDelegates = WeakArray<P2PNetworkPeerDelegate>()
    private var _dataHandlers = [String: WeakArray<DataHandler>]()

    fileprivate func onHostUpdate(host: Peer?) { // 호스트가 변경 되었을 때
        for delegate in _peerDelegates {
            delegate?.p2pNetwork(didUpdateHost: host) // 그 때 뭐해요? -> p2pNetwork
        }
    }

    fileprivate func onReceiveData(eventName: String, _ handleData: @escaping DataHandler.Callback) -> DataHandler {
        let handler = DataHandler(handleData)
        if let handlers = _dataHandlers[eventName] {
            handlers.add(handler)
        } else {
            _dataHandlers[eventName] = WeakArray<DataHandler>()
            _dataHandlers[eventName]?.add(handler)
        }
        return handler
    }

    fileprivate func addPeerDelegate(_ delegate: P2PNetworkPeerDelegate) {
        _peerDelegates.add(delegate)
    }

    fileprivate func removePeerDelegate(_ delegate: P2PNetworkPeerDelegate) {
        _peerDelegates.remove(delegate)
    }

    fileprivate func removeAllDelegates() {
        _peerDelegates = WeakArray<P2PNetworkPeerDelegate>()
    }
}

// P2PSession에서 연결 상태가 바뀌었을 때  _peerDelegates 배열(여러 명의 조수)에게 연결 상태 바뀐다고 알려주는 역할
extension P2PNetworkSessionListener: P2PSessionDelegate {
    func p2pSession(_: P2PSession, didUpdate peer: Peer) {
        guard !P2PNetwork.soloMode else { return }

        if P2PNetwork.currentTurnPlayerID.value.isEmpty {
            let candidates = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
            if let firstPlayer = candidates.randomElement() {
                P2PNetwork.currentTurnPlayerID.value = firstPlayer.id
            }
        }

        for peerDelegate in _peerDelegates {
            peerDelegate?.p2pNetwork(didUpdate: peer)
        }
    }

    func p2pSession(_: P2PSession, didReceive data: Data, dataAsJson json: [String: Any]?, from peerID: MCPeerID) {
        guard !P2PNetwork.soloMode else { return }

        if let eventName = json?["eventName"] as? String {
            if let handlers = _dataHandlers[eventName] {
                for handler in handlers {
                    handler?.callback(data, json, peerID)
                }
            }
        }

        if let handlers = _dataHandlers[""] {
            for handler in handlers {
                handler?.callback(data, json, peerID)
            }
        }
    }
}

extension String {
    func sha256() -> String {
        let data = Data(utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
