import Foundation
import SwiftyJSON

struct Link {
    let title: String
    let path: String
}

struct Event {
    enum Status : String {
        case ok
        case cancelled
    }

    let id: Int
    let name: String
    let venue: String
    let status: Status
    let date: Date?
    let url: URL?
}

extension Event {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["displayName"].stringValue
        self.venue = json["venue"]["displayName"].stringValue
        self.url = URL(string: json["uri"].stringValue)

        let status = json["status"].stringValue
        self.status = Status(rawValue: status) ?? .ok

        let date = json["start"]["date"].stringValue
        self.date = Event.dateFormatter.date(from: date)
    }
}

