//
//  PlayerProfileView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import MultipeerConnectivity
import P2PKit
import SwiftUI

struct PlayerProfileView: View {
    @StateObject var connected: ConnectedPeers

    var body: some View {
        HStack {
            HStack {
                // 본인 프로필
                VStack {
                    PlayerProfileComponentView(text: peerSummaryText(P2PNetwork.myPeer))
                }

                Spacer()
                    .frame(width: 30)

                // 다른 유저 프로필 슬롯
                HStack(spacing: 10) {
                    ForEach(0 ..< P2PNetwork.maxConnectedPeers, id: \.self) { index in
                        if index < connected.peers.count {
                            let peer = connected.peers[index]
                            PlayerProfileComponentView(text: peerSummaryText(peer))
                        } else {
                            EmptyProfileComponentView()
                        }
                    }
                }
            }
        }
    }

    private func peerSummaryText(_ peer: Peer) -> String {
        // 호스트한테 붙임
        let isHostString = connected.host?.peerID == peer.peerID ? " 🚀" : ""
        return peer.displayName + isHostString
    }
}

struct PlayerProfileComponentView: View {
    let text: String

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Circle()
                    .frame(width: 120, height: 120)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 130, height: 30)
                        .foregroundStyle(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 1)
                        )

                    Text(text)
                        .frame(width: 115)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
    }
}

struct EmptyProfileComponentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(width: 120, height: 120)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 130, height: 30)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

class ConnectedPeers: ObservableObject {
    @Published var peers = [Peer]()
    @Published var host: Peer? = nil

    init() {
//        P2PNetwork.addPeerDelegate(self)
//        p2pNetwork(didUpdate: P2PNetwork.myPeer)
    }

    func start() {
        P2PNetwork.addPeerDelegate(self)
        p2pNetwork(didUpdate: P2PNetwork.myPeer)
        P2PNetwork.start()
    }

    func out() {
        P2PNetwork.removePeerDelegate(self)
        P2PNetwork.removeAllDelegates()
    }

    deinit {
        P2PNetwork.removePeerDelegate(self)
    }
}

extension ConnectedPeers: P2PNetworkPeerDelegate {
    // 호스트가 변경 되었을 때
    func p2pNetwork(didUpdateHost host: Peer?) {
        DispatchQueue.main.async { [weak self] in
            self?.host = host
        }
    }

    // 연결된 사람의 상태가 바뀌었을 때
    func p2pNetwork(didUpdate _: Peer) {
        DispatchQueue.main.async { [weak self] in
            let limitedPeers = Array(P2PNetwork.connectedPeers.prefix(P2PNetwork.maxConnectedPeers))
            self?.peers = limitedPeers
//            if limitedPeers.count == 1 {
//                P2PNetwork.stopAcceptingPeers()
//            }
        }
    }
}

extension ConnectedPeers {
    static func preview(peers: [Peer], host: Peer?) -> ConnectedPeers {
        let instance = ConnectedPeers()
        instance.peers = peers
        instance.host = host
        return instance
    }
}
