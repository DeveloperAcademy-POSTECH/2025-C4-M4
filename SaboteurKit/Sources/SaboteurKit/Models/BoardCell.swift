

import Foundation

public struct BoardCell: CustomStringConvertible, Decodable, Encodable, Equatable {
    public var isCard: Bool = false
    public var directions: [Bool] = [true, true, true, true]
    public var symbol: String = "☐"
    public var imageName: String? = nil
    public var isConnect: Bool = false
    public var contributor: String = ""
    public var isGoal: Bool? = false
    public var isOpened: Bool? = false

    public init(isCard: Bool = false, directions: [Bool] = [true, true, true, true], symbol: String = "☐", imageName: String? = nil, isConnect: Bool = false, contributor: String = "", isGoal: Bool? = false, isOpened: Bool? = false) {
        self.isCard = isCard
        self.directions = directions
        self.symbol = symbol
        self.imageName = imageName
        self.isConnect = isConnect
        self.contributor = contributor
        self.isGoal = isGoal
        self.isOpened = isOpened
    }

    public var description: String {
        symbol
    }
}
