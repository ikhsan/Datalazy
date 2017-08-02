import Foundation

struct EventLinks {
    static let all = Link(title: "All Events", path: "/event/all")
    static let cancelled = Link(title: "Cancelled Events", path: "/event/cancelled")
    static let multiDay = Link(title: "Multi-day Festivals", path: "/event/multiday-fest")
    static let oneDay = Link(title: "One day Festivals", path: "/event/oneday-fest")

    static let links = [ all, cancelled, multiDay, oneDay ]
}

struct ArtistLinks {
    static let all = Link(title: "Artists", path: "/artist/all")

    static let links = [ all ]
}

struct VenueLinks {
    static let thousandIsland = Link(title: "Thousand Island", path: "/venue/1000-island")
    static let axis = Link(title: "Axis Planet Hollywood", path: "/venue/axis-planet-hollywood")
    static let unknownVenue = Link(title: "Unknown Venue", path: "/venue/unknown-venue")

    static let links = [ thousandIsland, axis, unknownVenue ]
}

struct TicketLinks {
    static let skTickets = Link(title: "SK Tickets", path: "/ticket/sk-tickets")
    static let futureOnsale = Link(title: "Future Onsale", path: "/ticket/future-onsale")

    static let links = [ skTickets, futureOnsale ]
}

func merge(_ localContext: [String : Any]) -> [String : Any] {
    var context : [String : Any] = [
        "links" : [
            "Event" : EventLinks.links,
            "Artist" : ArtistLinks.links,
            "Venue" : VenueLinks.links,
            "Ticket" : TicketLinks.links,
        ]
    ]
    localContext.forEach { context.updateValue($1, forKey: $0) }
    return context
}
