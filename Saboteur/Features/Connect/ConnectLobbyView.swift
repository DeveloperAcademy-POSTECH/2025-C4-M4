//
//  ConnectLobbyView.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import P2PKit
import SwiftUI

struct ConnectLobbyView<Content: View>: View {
    @StateObject var connected: DuoConnectedPeers
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Me")
                Text(peerSummaryText(P2PNetwork.myPeer))

                if (1 ... P2PNetwork.maxConnectedPeers).contains(connected.peers.count) {
                    Text("Connected Players")
                    ForEach(connected.peers.prefix(P2PNetwork.maxConnectedPeers), id: \.peerID) { peer in
                        Text(peerSummaryText(peer))
                    }
                } else {
                    Text("Searching for Players...")

                    ProgressView()
                }
            }

            VStack(spacing: 30) {
                content()
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: 480)
        .safeAreaPadding()
        .padding(EdgeInsets(top: 130, leading: 20, bottom: 100, trailing: 20))
    }

    private func peerSummaryText(_ peer: Peer) -> String {
        // 호스트한테 붙임
        let isHostString = connected.host?.peerID == peer.peerID ? " 🚀" : ""
        return peer.displayName + isHostString
    }
}

class DuoConnectedPeers: ObservableObject {
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

extension DuoConnectedPeers: P2PNetworkPeerDelegate {
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
