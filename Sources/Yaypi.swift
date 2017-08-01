import Foundation
import SwiftyJSON

enum YaypiError : Error {
    case pathError
    case misc
}

enum YaypiEndpoint {
    case londonConcerts
    case concert(id: Int)
    case artist(id: Int)


    var raw: String {
        switch self {

        case .londonConcerts:
            return "metro_areas/24426/calendar.json"

        case .concert(let id):
            return "events/\(id).json"

        case .artist(let id):
            return "artists/\(id).json"

        }
    }

}

struct Yaypi {

    let baseUrl = "https://api.songkick.com/api/3.0/"
    let apikey = "HkJnN1KOw3jAKDLL"

    func fetch(endpoint: YaypiEndpoint, page: Int = 1) throws -> JSON {
        guard var components = URLComponents(string: baseUrl + endpoint.raw) else {
            throw YaypiError.pathError
        }

        components.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "page", value: "\(page)"),
        ]

        let url = components.url!
        let data = try Data(contentsOf: url)
        let json = JSON(data: data)

        return json
    }
    
}
