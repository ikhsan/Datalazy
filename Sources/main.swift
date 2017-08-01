import Foundation
import Kitura
import HeliumLogger
import KituraStencil
import LoggerAPI

// MARK: Helpers
func stringFromEnv(_ key: String) -> String? {
    return ProcessInfo.processInfo.environment[key]
}

func intFromEnv(_ key: String) -> Int? {
    guard let value = ProcessInfo.processInfo.environment[key] else { return nil }
    return Int(value)
}

// MARK: Main app
do {

    HeliumLogger.use()

    let router = Router()
    router.all("/", middleware: StaticFileServer())
    router.add(templateEngine: StencilTemplateEngine())

    let controller = EventController()
    let mixpanel = try Mixpanel(apiSecret: stringFromEnv("MIXPANEL_API_SECRET"))

    router.get( "/" ) { request, response, next in
        try response.render("home.stencil", context: merge([:])).end()
    }

    router.get( EventLinks.all.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.all.title,
            "events": try controller.getAll()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.cancelled.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.cancelled.title,
            "events": try controller.getCancelledEvents()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.multiDay.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.multiDay.title,
            "events": try controller.getMultidayFestivals()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.oneDay.path ) { request, response, next in
        let context : [String : Any] = [
            "title": EventLinks.oneDay.title,
            "events": try controller.getSingleDayFestivals()
        ]

        try response.render("event_list.stencil", context: merge(context)).end()
    }

    router.get( EventLinks.futureOnsale.path ) { request, response, next in

        let ids = try mixpanel.getFutureOnsaleEventIds()
        let events = try controller.getEvents(ids: ids)

        let context : [String : Any] = [
            "title": EventLinks.futureOnsale.title,
            "events": events
        ]
        
        try response.render("event_list.stencil", context: merge(context)).end()
    }
    
    let port = intFromEnv("PORT") ?? 8080
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()

//    let events = try controller.getEvents(ids: [ 29427274, 30796314 ])
//    print("~~~~> " + String(describing: events))

} catch {
    fatalError("😵 dead 😵")
}
