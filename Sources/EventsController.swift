//let apikey = "HkJnN1KOw3jAKDLL"
//
//class EventController {
//
//    private var events: [Event] = []
//
//    private func fetchEventsFromAPI() throws -> [Event] {
//        let url = URL(string: "https://api.songkick.com/api/3.0/metro_areas/24426/calendar.json?apikey=\(apikey)&perPage=100")!
//        let data = try Data(contentsOf: url)
//        let json = JSON(data: data)
//        let jsonEvents = json["resultsPage"]["results"]["event"].arrayValue
//        return jsonEvents.map(Event.init(json:))
//    }
//
//    func getAll() throws -> Response {
//        if events.isEmpty {
//            events = try fetchEventsFromAPI()
//        }
//
//        let cancelledEvents = events.filter { $0.status == .cancelled && $0.url != nil }
//        let body = cancelledEvents.reduce("") { $0 + "<li /><a href='\($1.url!.absoluteString)'>\($1.name)</a>"}
//        return Response(body: "<html><ul>\(body)</ul></html>")
//    }
//    
//}