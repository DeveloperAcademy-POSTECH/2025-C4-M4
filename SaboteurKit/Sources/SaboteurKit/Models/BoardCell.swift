

import Foundation

public struct BoardCell: CustomStringConvertible {
    public var isCard: Bool = false
    public var directions: [Bool] = [true, true, true, true]
    public var symbol: String = "☐"
    public var isConnect: Bool = false
    public var contributor: String = ""

    public var description: String {
        symbol
    }
}
