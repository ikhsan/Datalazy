import Foundation
import Kitura
import HeliumLogger
import KituraStencil
import LoggerAPI

// MARK: - Helpers

func stringFromEnv(_ key: String) -> String? {
    return ProcessInfo.processInfo.environment[key]
}

func intFromEnv(_ key: String) -> Int? {
    guard let value = ProcessInfo.processInfo.environment[key] else { return nil }
    return Int(value)
}

// MARK: - Artist list

let artistList = [
    "longest": 3898176,
    "long": 2437841,
    "long+punctuation": 4301,
    "weird": 213283,
    "weird2": 99207
]

// MARK: - Main app

do {

    HeliumLogger.use()

    let router = Router()
    router.all("/", middleware: StaticFileServer())
    router.add(templateEngine: StencilTemplateEngine())

    let eventController = EventController()
    let artistController = ArtistController()

    
    // MARK: Populate data

    router.get( "/" ) { request, response, next in
        try response.render("home.stencil", context: merge([:])).end()
    }

    // MARK: Event Routes

    router.get( EventLinks.all.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.all.title,
            "events": try eventController.getAll()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.cancelled.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.cancelled.title,
            "events": try eventController.getCancelledEvents()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.multiDay.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.multiDay.title,
            "events": try eventController.getMultidayFestivals()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.oneDay.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.oneDay.title,
            "events": try eventController.getSingleDayFestivals()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    let mixpanel = try Mixpanel(apiSecret: stringFromEnv("MIXPANEL_API_SECRET"))
    let futureOnsaleEventIds = try mixpanel.getFutureOnsaleEventIds()
    let futureEvents = try eventController.getEvents(ids: futureOnsaleEventIds)

    router.get( EventLinks.futureOnsale.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.futureOnsale.title,
            "events": futureEvents,
        ]
        
        try response.render("event_list.stencil", context: merge(context)).end()
    }

    // MARK: Artists Routes

    router.get( ArtistLinks.all.path ) { request, response, next in
        let context : [String : Any] = [
            "title": ArtistLinks.all.title,
            "artists": try artistController.getArtists(),
        ]

        try response.render("artist_list.stencil", context: merge(context)).end()
    }

    // MARK: Venue Routes

    router.get( VenueLinks.unknownVenue.path ) { request, response, next in
        let context : [String : Any] = [
            "title": VenueLinks.thousandIsland.title,
            "events": try eventController.getUnknownVenueEvents(),
        ]
        try response.render("event_list.stencil", context: merge(context)).end()
    }

    let thousandIslandEvents = try eventController.getEvents(venueId: 434301)

    router.get( VenueLinks.thousandIsland.path ) { request, response, next in
        let context : [String : Any] = [
            "title": VenueLinks.thousandIsland.title,
            "events": thousandIslandEvents,
        ]
        try response.render("event_list.stencil", context: merge(context)).end()
    }

    let axisEvents = try eventController.getEvents(venueId: 2502809)

    router.get( VenueLinks.axis.path ) { request, response, next in
        let context : [String : Any] = [
            "title": VenueLinks.axis.title,
            "events": axisEvents
        ]
        try response.render("event_list.stencil", context: merge(context)).end()
    }

    let salleEvents = try eventController.getEvents(venueId: 1405958)

    router.get( VenueLinks.salle.path ) { request, response, next in
        let context : [String : Any] = [
            "title": VenueLinks.salle.title,
            "events": salleEvents
        ]
        try response.render("event_list.stencil", context: merge(context)).end()
    }

    // MARK: Start our engine!
    
    let port = intFromEnv("PORT") ?? 8080
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()

} catch {
    fatalError("😵 dead 😵")
}
