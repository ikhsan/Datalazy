
typealias JsonObject = [String : Any]

class EventController {

    private let api = Yaypi()
    private var events: [Event] = []

    private let hasUrl: (Event) -> Bool = { $0.url != nil }
    private let cancelled: (Event) -> Bool = { $0.status == .cancelled }
    private let isFestival: (Event) -> Bool = { $0.type == .festival }
    private let isMultiDay: (Event) -> Bool = { $0.startDate != $0.endDate }
    private let isSingleDay: (Event) -> Bool = { $0.startDate == $0.endDate }

    private func fetchEvents(page: Int) throws -> [Event] {
        let json = try api.fetch(endpoint: .londonConcerts, page: page)
        let jsonEvents = json["resultsPage"]["results"]["event"].arrayValue
        return jsonEvents.map(Event.init(json:))
    }

    private func getEvents() throws -> [Event] {
        if events.isEmpty {
            let page1 = try fetchEvents(page: 1)
            events.append(contentsOf: page1)

            let page2 = try fetchEvents(page: 2)
            events.append(contentsOf: page2)

            let page3 = try fetchEvents(page: 3)
            events.append(contentsOf: page3)
        }

        return events
    }

    func getAll() throws -> [JsonObject] {
        return try getEvents().map { $0.toJSON }
    }

    func getCancelledEvents() throws -> [JsonObject] {
        return try getEvents()
            .filter(hasUrl)
            .filter(cancelled)
            .map { $0.toJSON }
    }

    func getSingleDayFestivals() throws -> [JsonObject] {
        return try getEvents()
            .filter(hasUrl)
            .filter(isFestival)
            .filter(isSingleDay)
            .map { $0.toJSON }
    }

    func getMultidayFestivals() throws -> [JsonObject] {
        return try getEvents()
            .filter(hasUrl)
            .filter(isFestival)
            .filter(isMultiDay)
            .map { $0.toJSON }
    }

}
