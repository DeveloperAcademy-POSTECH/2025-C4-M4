import Foundation

public enum CardType: String, Codable, Hashable, CaseIterable, Sendable {
    // 길 카드
    case pathTL, pathTR, pathTB, pathRL
    case pathTRB, pathTRL, pathTRBL

    // 방해 카드
    case blockT, blockL, blockTL, blockTR, blockTB, blockRL
    case blockTRB, blockTRL, blockTRBL

    // 길 카드 180도 회전
    case pathB, pathBL, pathRB, pathRBL, pathTBL

    // 방해 카드 180도 회전
    case blockB, blockBL, blockR, blockRB, blockRBL, blockTBL

    // 스킬 카드
    case bomb
    case map

    // 시작/도착 카드
    case start
    case goalTrue
    case goalFalse
    case goalHidden
}

public extension CardType {
    /// 회전된 방향과 연결 여부를 기반으로 CardType을 역으로 찾아냄
    static func from(directions: [Bool], connect: Bool) -> CardType? {
        allCases.first {
            $0.directions == directions && $0.connect == connect
        }
    }

    /// 시계 방향 기준 [top, right, bottom, left]
    var directions: [Bool] {
        switch self {
        case .pathTL: [true, false, false, true]
        case .pathTR: [true, true, false, false]
        case .pathTB: [true, false, true, false]
        case .pathRL: [false, true, false, true]
        case .pathTRB: [true, true, true, false]
        case .pathTRL: [true, true, false, true]
        case .pathTRBL: [true, true, true, true]
        case .pathB: [false, false, true, false]
        case .pathBL: [false, false, true, true]
        case .pathRB: [false, true, true, false]
        case .pathRBL: [false, true, true, true]
        case .pathTBL: [true, false, true, true]
        case .blockT: [true, false, false, false]
        case .blockL: [false, false, false, true]
        case .blockTL: [true, false, false, true]
        case .blockTR: [true, true, false, false]
        case .blockTB: [true, false, true, true]
        case .blockRL: [false, true, false, true]
        case .blockTRB: [true, true, true, false]
        case .blockTRL: [true, true, false, true]
        case .blockTRBL: [true, true, true, true]
        case .blockB: [false, false, true, false]
        case .blockBL: [false, false, true, true]
        case .blockR: [false, true, false, false]
        case .blockRB: [false, true, true, false]
        case .blockRBL: [false, true, true, true]
        case .blockTBL: [true, false, true, true]
        case .bomb, .map: [false, false, false, false]
        case .start, .goalTrue, .goalFalse, .goalHidden:
            [true, true, true, true]
        }
    }

    /// 해당 카드가 연결 가능한 경로 카드인지 여부
    var connect: Bool {
        switch self {
        case .pathTL, .pathTR, .pathTB, .pathRL,
             .pathTRB, .pathTRL, .pathTRBL, .pathB,
             .pathBL, .pathRB, .pathRBL, .pathTBL,
             .start, .goalTrue, .goalFalse, .goalHidden:
            return true
        default:
            return false
        }
    }

    /// 카드에 표시할 대표 이모지/심볼
    var symbol: String {
        switch self {
        case .bomb: "💣"
        case .map: "🗺"
        case .start: "Ⓢ"
        case .goalTrue: "G1"
        case .goalFalse: "G2"
        case .goalHidden: "G?"
        case .pathTL: "┘"
        case .pathTR: "└"
        case .pathTB: "│"
        case .pathRL: "─"
        case .pathTRB: "├"
        case .pathTRL: "ㅗ"
        case .pathTRBL: "┼"
        case .blockT: "▴"
        case .blockL: "◀︎"
        case .blockTL: "▴◀︎"
        case .blockTR: "╰"
        case .blockTB: "▴▾"
        case .blockRL: "◀︎‣"
        case .blockTRB: "▴‣▾"
        case .blockTRL: "▴‣◀︎"
        case .blockTRBL: "╳"
        case .pathB: "▾"
        case .pathBL: "◀︎▾"
        case .pathRB: "‣▾"
        case .pathRBL: "‣▾◀︎"
        case .pathTBL: "▴▾◀︎"
        case .blockB: "▾x"
        case .blockBL: "◀︎▾x"
        case .blockR: "‣x"
        case .blockRB: "‣▾x"
        case .blockRBL: "‣▾◀︎x"
        case .blockTBL: "▴▾◀︎x"
        }
    }

    /// 카드에 대응되는 이미지 파일명
    var imageName: String {
        switch self {
        case .pathTL: "Card/Road/tl"
        case .pathTR: "Card/Road/tr"
        case .pathTB: "Card/Road/tb"
        case .pathRL: "Card/Road/rl"
        case .pathTRB: "Card/Road/trb"
        case .pathTRL: "Card/Road/trl"
        case .pathTRBL: "Card/Road/trbl"
        case .blockT: "Card/Road/t_block"
        case .blockL: "Card/Road/l_block"
        case .blockTL: "Card/Road/tl_block"
        case .blockTR: "Card/Road/tr_block"
        case .blockTB: "Card/Road/tb_block"
        case .blockRL: "Card/Road/rl_block"
        case .blockTRB: "Card/Road/trb_block"
        case .blockTRL: "Card/Road/trl_block"
        case .blockTRBL: "Card/Road/trbl_block"
        case .pathB: "Card/Road/b"
        case .pathBL: "Card/Road/bl"
        case .pathRB: "Card/Road/rb"
        case .pathRBL: "Card/Road/rbl"
        case .pathTBL: "Card/Road/tbl"
        case .blockB: "Card/Road/b_block"
        case .blockBL: "Card/Road/bl_block"
        case .blockR: "Card/Road/r_block"
        case .blockRB: "Card/Road/rb_block"
        case .blockRBL: "Card/Road/rbl_block"
        case .blockTBL: "Card/Road/tbl_block"
        case .bomb: "Card/Skill/bomb"
        case .map: "Card/Skill/map"
        case .start: "Card/start_2"
        case .goalTrue: "Card/Goal/true_2"
        case .goalFalse: "Card/Goal/false_2"
        case .goalHidden: "Card/Goal/hidden"
        }
    }
}

public struct Card: Identifiable, Sendable, Equatable {
    public let id: UUID = .init()
    public var type: CardType

    public init(type: CardType) {
        self.type = type
    }

    public mutating func rotate180() {
        let d = type.directions
        let rotated = [d[2], d[3], d[0], d[1]]

        if let newType = CardType.from(directions: rotated, connect: type.connect) {
            type = newType
        } else {
            print("❌ 회전 후 매칭되는 CardType이 없습니다! 현재 방향: \(rotated)")
            assertionFailure("Invalid rotation result: no matching CardType found.")
        }
    }
}
