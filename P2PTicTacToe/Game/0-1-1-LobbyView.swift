//
//  0-1-1-LobbyView.swift
//  P2PKitDemo
//
//  Created by Paige Sun on 5/23/24.
//

import P2PKit
import SwiftUI

struct LobbyView<Content: View>: View {
    @StateObject var connected: DuoConnectedPeers
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("Me").p2pTitleStyle()
                Text(peerSummaryText(P2PNetwork.myPeer))

                if connected.peers.count == 1 {
                    Text("Connected Players").p2pTitleStyle()
                    ForEach(connected.peers.prefix(1), id: \.peerID) { peer in
                        Text(peerSummaryText(peer))
                    }
                } else {
                    Text("Searching for Players...")
                        .p2pTitleStyle()
                    ProgressView()
                }
            }
            Spacer()
            VStack(spacing: 30) {
                content()
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: 480)
        .safeAreaPadding()
        .padding(EdgeInsets(top: 130, leading: 20,
                            bottom: 100, trailing: 20))
    }

    private func peerSummaryText(_ peer: Peer) -> String {
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

    deinit {
        P2PNetwork.removePeerDelegate(self)
    }
}

extension DuoConnectedPeers: P2PNetworkPeerDelegate {
    func p2pNetwork(didUpdateHost host: Peer?) {
        DispatchQueue.main.async { [weak self] in
            self?.host = host
        }
    }

    func p2pNetwork(didUpdate _: Peer) {
        DispatchQueue.main.async { [weak self] in
            let limitedPeers = Array(P2PNetwork.connectedPeers.prefix(1))
            self?.peers = limitedPeers
//            if limitedPeers.count == 1 {
//                P2PNetwork.stopAcceptingPeers()
//            }
        }
    }
}
