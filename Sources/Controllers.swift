import HeliumLogger
import LoggerAPI

typealias JsonObject = [String : Any]

fileprivate let api = Yaypi()

class EventController {

    private var events: [Event] = []

    private let hasUrl: (Event) -> Bool = { $0.url != nil }
    private let cancelled: (Event) -> Bool = { $0.status == .cancelled }
    private let isFestival: (Event) -> Bool = { $0.type == .festival }
    private let isMultiDay: (Event) -> Bool = { $0.startDate != $0.endDate }
    private let isSingleDay: (Event) -> Bool = { $0.startDate == $0.endDate }

    init() {
        _ = try? getEvents()
    }

    private func fetchEvents(page: Int) throws -> [Event] {
        let json = try api.fetch(endpoint: .londonConcerts, page: page)
        let jsonEvents = json["resultsPage"]["results"]["event"].arrayValue
        return jsonEvents.map(Event.init(json:))
    }

    private func fetchEvents(venueId: Int) throws -> [Event] {
        let json = try api.fetch(endpoint: .concerts(venueId: venueId))
        let jsonEvents = json["resultsPage"]["results"]["event"].arrayValue
        return jsonEvents.map(Event.init(json:))
    }

    private func fetchEvent(id: Int) throws -> Event {
        let eventExists = events.contains(where: { $0.id == id })
        guard !eventExists else { throw YaypiError.misc }

        let json = try api.fetch(endpoint: .concert(id: id))
        let eventJson = json["resultsPage"]["results"]["event"]

        return Event(json: eventJson)
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

    private func addEvents(_ newEvents: [Event]) {
        let result = newEvents.filter { !self.events.contains($0) }
        events.append(contentsOf: result)
    }

    func getAll() throws -> [JsonObject] {
        return try getEvents()
            .map { $0.toJSON }
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

    func getEvents(ids: [Int]) throws -> [JsonObject] {
        let availableIds = self.events.map({ $0.id })
        let idsToFetch = ids.filter({ !availableIds.contains($0) })

        let events = idsToFetch.flatMap { try? fetchEvent(id: $0) }
        addEvents(events)

        return try getEvents()
            .filter { ids.contains($0.id) }
            .map { $0.toJSON }
    }

    // Venue related

    func getEvents(venueId: Int) throws -> [JsonObject] {
        let events = try fetchEvents(venueId: venueId)
        addEvents(events)

        return try getEvents()
            .filter { $0.venueId == venueId }
            .map { $0.toJSON }
    }

    func getUnknownVenueEvents() throws -> [JsonObject] {
        return try getEvents()
            .filter { $0.venueId == 0 }
            .map { $0.toJSON }
    }


}


class ArtistController {

    private var artists: [String: Artist] = [:]

    private func fetchArtist(id: Int) throws -> Artist {
        let json = try api.fetch(endpoint: .artist(id: id))
        let artistJson = json["resultsPage"]["results"]["artist"]

        return Artist(json: artistJson)
    }

    init() {
        try? populateArtists()
    }

    private func populateArtists() throws {
        self.artists = artistList.reduce([String: Artist](), { (memo, keyValue) -> [String: Artist] in
            var result = memo

            let key = keyValue.key
            let artistId = keyValue.value

            if let artist = try? fetchArtist(id: artistId) {
                result[key] = artist
            }

            return result
        })
    }

    func getArtists() throws -> [String : JsonObject] {
        return artists.reduce([String : JsonObject]()) { (memo, keyValue) -> [String : JsonObject] in
            var result = memo
            result[keyValue.key] = keyValue.value.toJSON
            return result
        }
    }

}



