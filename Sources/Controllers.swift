// import Foundation
// import SwiftyJSON
// import HTTPServer
//
// struct Event {
//     enum Status : String {
//         case ok
//         case cancelled
//     }
//
//     let id: Int
//     let name: String
//     let venue: String
//     let status: Status
//     let date: Date?
//     let url: URL?
// }
//
// extension Event {
//     static let dateFormatter: DateFormatter = {
//         let formatter = DateFormatter()
//         formatter.dateFormat = "yyyy-MM-dd"
//         return formatter
//     }()
//
//     init(json: SwiftyJSON.JSON) {
//         self.id = json["id"].intValue
//         self.name = json["displayName"].stringValue
//         self.venue = json["venue"]["displayName"].stringValue
//         self.url = URL(string: json["uri"].stringValue)
//
//         let status = json["status"].stringValue
//         self.status = Status(rawValue: status) ?? .ok
//
//         let date = json["start"]["date"].stringValue
//         self.date = Event.dateFormatter.date(from: date)
//     }
// }
//
// class EventController {
//
//     private var events: [Event] = []
//
//     private func fetchEventsFromAPI() throws -> [Event] {
//         let url = URL(string: "https://api.songkick.com/api/3.0/metro_areas/24426/calendar.json?apikey=\(apikey)&perPage=100")!
//         let data = try Data(contentsOf: url)
//         let json = JSON(data: data)
//         let jsonEvents = json["resultsPage"]["results"]["event"].arrayValue
//         return jsonEvents.map(Event.init(json:))
//     }
//
//     func getAll() throws -> Response {
//         if events.isEmpty {
//             events = try fetchEventsFromAPI()
//         }
//
//         let cancelledEvents = events.filter { $0.status == .cancelled && $0.url != nil }
//         let body = cancelledEvents.reduce("") { $0 + "<li /><a href='\($1.url!.absoluteString)'>\($1.name)</a>"}
//         return Response(body: "<html><ul>\(body)</ul></html>")
//     }
//
// }
//
// extension URL {
//
//     public var ixn_queryParameters: [String : String] {
//         let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
//         guard let items = components?.queryItems else {
//             return [:]
//         }
//
//         return items.reduce([String : String]()) { initial, item in
//             var result = initial
//             if let value = item.value {
//                 result[item.name] = value
//             }
//             return result
//         }
//     }
//
// }
//
