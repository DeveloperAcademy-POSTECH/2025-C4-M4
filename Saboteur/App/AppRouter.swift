//
//  AppRouter.swift
//  Saboteur
//
//  Created by 이주현 on 7/15/25.
//

import Foundation
import SwiftUI

enum AppScreen {
    case lobby
    case choosePlayer
    case connect

    case none
}

class AppRouter: ObservableObject {
    @Published var currentScreen: AppScreen = .lobby
}
