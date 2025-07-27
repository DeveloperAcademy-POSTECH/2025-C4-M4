//
//  GroupVerificationMessage.swift
//  Saboteur
//
//  Created by Baba on 7/27/25.
//

import Foundation

// 그룹 검증 메시지 구조체
struct GroupVerificationMessage: Codable {
    let peerIDs: [String]
}
