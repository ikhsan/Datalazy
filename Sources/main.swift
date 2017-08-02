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

    let mixpanel = try Mixpanel(apiSecret: stringFromEnv("MIXPANEL_API_SECRET"))
    let futureOnsaleEventIds = try mixpanel.getFutureOnsaleEventIds()
    let futureEvents = try eventController.getEvents(ids: futureOnsaleEventIds)

    let skTicketsIds = try mixpanel.getSKTicketEventIds()
    let skTicketsEvents = try eventController.getEvents(ids: skTicketsIds)

    let thousandIslandEvents = try eventController.getEvents(venueId: 434301)
    let axisEvents = try eventController.getEvents(venueId: 2502809)

    // MARK: Event Routes

    struct Route {
        let link: Link
        let template: String
        let context: [String : Any]
    }

    func registerRoutes(_ routes: [Route])  {
        for aRoute in routes {

            router.get(aRoute.link.path) { request, response, next in
                var context = aRoute.context
                context["title"] = aRoute.link.title
                try response.render(aRoute.template, context: merge(context)).end()
            }

        }
    }

    registerRoutes([

        Route(
            link: Link(title: "Home", path: "/"),
            template: "home.stencil",
            context: [:]
        ),

        // MARK: - Events

        Route(link: EventLinks.all, template: "event_list.stencil", context: [
            "events" : try eventController.getAll()
        ]),

        Route(link: EventLinks.cancelled, template: "event_list.stencil", context: [
            "events" : try eventController.getCancelledEvents()
        ]),

        Route(link: EventLinks.multiDay, template: "event_list.stencil", context: [
            "events" : try eventController.getMultidayFestivals()
        ]),

        Route(link: EventLinks.oneDay, template: "event_list.stencil", context: [
            "events" : try eventController.getSingleDayFestivals()
        ]),

        // MARK: - Tickets

        Route(link: TicketLinks.futureOnsale, template: "event_list.stencil", context: [
            "events" : futureEvents
        ]),

        Route(link: TicketLinks.skTickets, template: "event_list.stencil", context: [
            "events" : skTicketsEvents
        ]),

        // MARK: - Artists

        Route(link: ArtistLinks.all, template: "artist_list.stencil", context: [
            "artists" : try artistController.getArtists()
        ]),

        // MARK: - Venues

        Route(link: VenueLinks.thousandIsland, template: "event_list.stencil", context: [
            "events" : thousandIslandEvents
        ]),

        Route(link: VenueLinks.axis, template: "event_list.stencil", context: [
            "events" : axisEvents
        ]),

        Route(link: VenueLinks.unknownVenue, template: "event_list.stencil", context: [
            "events" : try eventController.getUnknownVenueEvents()
        ]),

    ])


    // MARK: Start our engine!
    
    let port = intFromEnv("PORT") ?? 8080
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()

} catch {
    fatalError("😵 dead 😵")
}
