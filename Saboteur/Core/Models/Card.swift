

import Foundation

struct Card {
    let directions: [Bool]
    let connect: Bool
    let symbol: String

    var description: String {
        symbol
    }
}
