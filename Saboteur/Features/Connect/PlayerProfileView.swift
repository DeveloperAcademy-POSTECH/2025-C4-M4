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
        // Create a shuffled list of 4 unique styles
        let shuffledStyles = Array(PlayerProfileComponentView.stylePresets.shuffled().prefix(4))
        HStack {
            HStack {
                // 본인 프로필
                let selectedStyle = shuffledStyles[0]
                VStack {
                    PlayerProfileComponentView(text: peerSummaryText(P2PNetwork.myPeer), style: selectedStyle, showBackground: true)
                }

                Spacer()
                    .frame(width: 32)

                // 다른 유저 프로필 슬롯
                HStack(spacing: 8) {
                    // Only up to 3 peers, as we have 4 unique styles (first for self)
                    ForEach(0 ..< P2PNetwork.maxConnectedPeers, id: \.self) { index in
                        if index < connected.peers.count, index < 3 {
                            let peer = connected.peers[index]
                            let style = shuffledStyles[index + 1]
                            PlayerProfileComponentView(text: peerSummaryText(peer), style: style, showBackground: false)
                        } else {
                            Image("Empty_Profile")
                                .resizable()
                                .frame(width: 170, height: 215)
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
    static let stylePresets: [(image: ImageResource, color: Color, fill: Color)] = [
        (.blackAirplane, Color.Grayscale.gray2, Color(hex: "575450")),
        (.blueAirplane, Color.Secondary.blue3, Color(hex: "4AB1BE")),
        (.greenAirplane, Color.Etc.mint, Color.Etc.mintdeep),
        (.pinkAirplane, Color.Etc.red, Color.Etc.reddeep),
        (.yellowAirplane, Color.Etc.orange, Color.Etc.orangedeep),
    ]

    let text: String
    let style: (image: ImageResource, color: Color, fill: Color)
    let showBackground: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(showBackground ? style.fill : Color.Ivory.ivory1)
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2)

            VStack(spacing: 20) {
                Image(style.image)
                    .resizable()
                    .frame(width: 122, height: 122)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 122, height: 30)
                        .foregroundStyle(showBackground ? Color.Grayscale.whiteBg.opacity(0.3) : style.color)

                    Text(text)
                        .foregroundStyle(showBackground ? Color.white : Color.Grayscale.black)
                        .frame(width: 105)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .padding()
        }
        .frame(width: 170, height: 215)
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
