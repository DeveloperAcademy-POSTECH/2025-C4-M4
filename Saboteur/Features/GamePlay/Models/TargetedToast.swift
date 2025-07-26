//
//  TargetedToast.swift
//  Saboteur
//
//  Created by kirby on 7/26/25.
//

struct TargetedToast: Codable, Equatable {
    let message: String
    let target: ToastTarget
    let senderID: String
}
