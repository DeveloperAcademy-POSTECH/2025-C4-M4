//
//  Keyboard+extension.swift
//  Saboteur
//
//  Created by 이주현 on 7/27/25.
//

import Foundation
import SwiftUI

extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
