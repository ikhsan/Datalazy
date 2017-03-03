import Foundation
import SwiftyJSON

enum YaypiError : Error {
    case pathError
}

enum YaypiEndpoint : String {
    case londonConcerts = "metro_areas/24426/calendar.json"
}

struct Yaypi {

    let baseUrl = "https://api.songkick.com/api/3.0/"
    let apikey = "HkJnN1KOw3jAKDLL"

    func fetch(endpoint: YaypiEndpoint, page: Int = 1) throws -> JSON {
        guard var components = URLComponents(string: baseUrl + endpoint.rawValue) else {
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
