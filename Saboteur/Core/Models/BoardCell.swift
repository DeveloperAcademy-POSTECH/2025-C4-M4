import Foundation

struct BoardCell: CustomStringConvertible, Decodable, Encodable, Equatable {
    var isCard: Bool = false
    var directions: [Bool] = [true, true, true, true]
    var symbol: String = "☐"
    var isConnect: Bool = false
    var contributor: String = ""

    var description: String {
        symbol
    }
}
