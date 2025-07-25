//
//  Peer.swift
//  P2PKitExample
//
//  Created by Paige Sun on 4/24/24.
//

import MultipeerConnectivity

public struct Peer {
    public typealias Identifier = String

    public let id: Identifier
    public let peerID: MCPeerID
    public var displayName: String { peerID.displayName }

    public init(_ peerID: MCPeerID, id: String) {
        self.id = id
        self.peerID = peerID
    }

    public var isMe: Bool {
        peerID == P2PNetwork.myPeer.peerID
    }
}

extension Peer: Hashable {
    public static func == (lhs: Peer, rhs: Peer) -> Bool {
        lhs.peerID == rhs.peerID
    }

    public func hash(into hasher: inout Hasher) {
        peerID.hash(into: &hasher)
    }
}

// My Peer
extension Peer {
    // swiftlint:disable force_try
    static func getMyPeer() -> Peer {
        if let data = UserDefaults.standard.data(forKey: P2PConstants.UserDefaultsKeys.myMCPeerID),
           //
           let peerID = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data),
           let id = UserDefaults.standard.string(forKey: P2PConstants.UserDefaultsKeys.myPeerID)
        {
            return Peer(peerID, id: id)
        } else {
            let initialName = "TEMP_USER_\(UUID().uuidString.prefix(4))"
            let peerID = MCPeerID(displayName: "\(initialName)")
            return resetMyPeer(with: peerID)
        }
    }

    static func resetMyPeer(with peerID: MCPeerID) -> Peer {
        let data = try! NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true)
        let id = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.set(data, forKey: P2PConstants.UserDefaultsKeys.myMCPeerID)
        UserDefaults.standard.set(id, forKey: P2PConstants.UserDefaultsKeys.myPeerID)
        return Peer(peerID, id: id)
    }
    // swiftlint:enable force_try
}
