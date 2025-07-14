import SwiftData

/// 앱 전체에서 SwiftData의 ModelContainer를 싱글톤으로 관리하는 클래스입니다.
/// - ModelContainer는 SwiftData 기반의 영속성 컨테이너로, 데이터 모델을 등록해 사용합니다.
/// - App, View 등에서 `SwiftDataContainer.shared.container`로 접근해 일관된 데이터 환경을 제공합니다.
final class SwiftDataContainer {
    static let shared = SwiftDataContainer()
    let container: ModelContainer
    private init() {
        let schema = Schema([
            // 모델 추가
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
