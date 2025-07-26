//
//  ToastTarget.swift
//  Saboteur
//
//  Created by kirby on 7/26/25.
//

enum ToastTarget: String, Codable {
    case personal // 본인에게만 표시
    case global // 모두에게 표시
    case other // 본인을 제외한 다른 플레이어에게 표시
}
