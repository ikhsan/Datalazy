import Foundation
import SwiftyJSON

// MARK: - Link

struct Link {
    let title: String
    let path: String
}

// MARK: - Artist

struct Artist {
    let id: Int
    let name: String
    let url: URL?
}

extension Artist {

    init(json: JSON) {
        self.id = json["id"].intValue
        self.name = json["displayName"].stringValue
        self.url = URL(string: json["uri"].stringValue)
    }

    var toJSON: [String : Any] {
        return [
            "id" : id,
            "name" : name,
            "url" : url?.absoluteString ?? ""
        ]
    }

}

extension Artist : Equatable {

    static func ==(lhs: Artist, rhs: Artist) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        guard lhs.url == rhs.url else { return false }

        return true
    }


}

// MARK: - Event

struct Event {
    enum Status : String {
        case ok
        case cancelled
    }

    enum `Type` : String {
        case festival = "Festival"
        case concert = "Concert"
    }

    let id: Int
    let name: String
    let venue: String
    let venueId: Int
    let status: Status
    let type: Type
    let startDate: Date?
    let endDate: Date?
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
        self.venueId = json["venue"]["id"].intValue
        self.url = URL(string: json["uri"].stringValue)

        let status = json["status"].stringValue
        self.status = Status(rawValue: status) ?? .ok

        let type = json["type"].stringValue
        self.type = Type(rawValue: type) ?? .concert

        let startDate = json["start"]["date"].stringValue
        self.startDate = Event.dateFormatter.date(from: startDate)

        let endDate = json["end"]["date"].stringValue
        self.endDate = Event.dateFormatter.date(from: endDate)
    }

    var toJSON: [String : Any] {
        return [
            "name" : name,
            "url" : url?.absoluteString ?? "",
            "status" : status.rawValue
        ]
    }
}

extension Event : Equatable {

    static func ==(lhs: Event, rhs: Event) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.name == rhs.name else { return false }
        guard lhs.venue == rhs.venue else { return false }
        guard lhs.status == rhs.status else { return false }
        guard lhs.type == rhs.type else { return false }

        return true
    }

}
