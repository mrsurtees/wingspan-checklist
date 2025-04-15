import Foundation

struct WingSpanAircraft: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var modelName: String
    var manufacturer: String
    var imageName: String

    static func == (lhs: WingSpanAircraft, rhs: WingSpanAircraft) -> Bool {
        lhs.id == rhs.id && lhs.modelName == rhs.modelName
    }
}

enum ChecklistItemStatus: String, Codable {
    case notCompleted
    case completed
    case failed
}

struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var status: ChecklistItemStatus = .notCompleted
}

struct ChecklistSection: Identifiable, Codable {
    var id = UUID()
    var title: String
    var items: [ChecklistItem]
}
