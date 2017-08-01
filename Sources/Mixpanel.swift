import Foundation
import SwiftyJSON

class Mixpanel {

    let baseUrl = "https://mixpanel.com/api/2.0"
    let apiSecret: String

    init(apiSecret: String?) throws {
        guard let apiSecret = apiSecret else { throw YaypiError.misc }
        self.apiSecret = apiSecret
    }

    func fetch(path: String, params: [String : String]) throws -> JSON {
        guard var components = URLComponents(string: baseUrl + "/events/properties/") else {
            throw YaypiError.pathError
        }

        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        components.user = apiSecret
        components.password = ""

        let url = components.url!
        let data = try Data(contentsOf: url)
        let json = JSON(data: data)
        
        return json

    }

    func getFutureOnsaleEventIds(date: Date = Date(), limit: Int = 20) throws -> [Int] {
        let dateString = Event.dateFormatter.string(from: date)
        let json = try fetch(path: "/events/properties/", params: [
            "from_date": dateString,
            "to_date": dateString,
            "event": "tap_button_notify_me - concert_details",
            "name": "event_id",
            "type": "unique",
            "unit": "day",
        ])

        let values = Array(json["data"]["values"].dictionaryValue.keys.prefix(limit))
        return values.flatMap { Int($0) }
    }

    func getSKTicketEventIds(date: Date = Date(), limit: Int = 20) throws -> [Int] {
        let dateString = Event.dateFormatter.string(from: date)
        let json = try fetch(path: "/events/properties/", params: [
            "from_date": dateString,
            "to_date": dateString,
            "event": "tap_button_SK_ticket_button - concert_details",
            "name": "SK_event_id",
            "type": "unique",
            "unit": "day",
        ])

        let values = Array(json["data"]["values"].dictionaryValue.keys.prefix(limit))
        return values.flatMap { Int($0) }
    }

}
