import Foundation
import SwiftData

/// 예시 모델이므로 추후 삭제
@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
