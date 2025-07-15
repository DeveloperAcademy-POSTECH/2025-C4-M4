//
//  P2PNetwork.swift
//  P2PKitExample
//
//  Created by Paige Sun on 5/2/24.
//

import SwiftUI

import Foundation
import MultipeerConnectivity

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
    public static var currentTurnPlayerName = P2PSyncedObservable(name: "currentTurnPlayerName", initial: "")

    private static var session = P2PSession(myPeer: Peer.getMyPeer())
    private static let sessionListener = P2PNetworkSessionListener()
    private static let hostSelector: P2PHostSelector = {
        let hostSelector = P2PHostSelector()
        hostSelector.onHostUpdateHandler = { host in
            sessionListener.onHostUpdate(host: host)
        }
        return hostSelector
    }()

    // MARK: - Public P2PHostSelector

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
//        if currentTurnPlayerName.value.isEmpty {
//            // Randomly assign the first turn to one of the peers including self
//            let candidates = [myPeer] + connectedPeers
//            if let firstPlayer = candidates.randomElement() {
//                currentTurnPlayerName.value = firstPlayer.displayName
//            }
//        }
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
        session.start()
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

        if P2PNetwork.currentTurnPlayerName.value.isEmpty {
            let candidates = [P2PNetwork.myPeer] + P2PNetwork.connectedPeers
            if let firstPlayer = candidates.randomElement() {
                P2PNetwork.currentTurnPlayerName.value = firstPlayer.displayName
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
