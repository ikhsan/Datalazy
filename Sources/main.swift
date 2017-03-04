import Foundation
import Kitura
import HeliumLogger
import KituraStencil
import LoggerAPI

// MARK: Helpers
func portFromEnv() -> Int? {
    guard let envPort = ProcessInfo.processInfo.environment["PORT"] else { return nil }
    return Int(envPort)
}

let allLink =      Link(title: "All Events", path: "/all")
let cancelledLink = Link(title: "Cancelled Events", path: "/cancelled")
let multiDayLink =  Link(title: "Multi-day Festivals", path: "/multiday_fest")
let oneDayLink =    Link(title: "One day Festivals", path: "/oneday_fest")
let mainLinks : [String : Any] = [
    "links" : [ allLink, cancelledLink, multiDayLink, oneDayLink ]
]

fileprivate func merge(_ localContext: [String : Any]) -> [String : Any] {
    var context = mainLinks
    localContext.forEach { context.updateValue($1, forKey: $0) }
    return context
}

// MARK: Main app

HeliumLogger.use()

let router = Router()
router.all("/", middleware: StaticFileServer())
router.add(templateEngine: StencilTemplateEngine())

let controller = EventController()

router.get( "/" ) { request, response, next in
    let context = mainLinks
    try response.render("home.stencil", context: context).end()
}


router.get( allLink.path ) { request, response, next in
    let context : [String : Any] = [
        "title": allLink.title,
        "events": try controller.getAll()
    ]

    try response.render("event_list.stencil", context: merge(context)).end()
}

router.get( cancelledLink.path ) { request, response, next in
    let context : [String : Any] = [
        "title": cancelledLink.title,
        "events": try controller.getCancelledEvents()
    ]

    try response.render("event_list.stencil", context: merge(context)).end()
}

router.get( multiDayLink.path ) { request, response, next in
    let context : [String : Any] = [
        "title": multiDayLink.title,
        "events": try controller.getMultidayFestivals()
    ]

    try response.render("event_list.stencil", context: merge(context)).end()
}

router.get( oneDayLink.path ) { request, response, next in
    let context : [String : Any] = [
        "title": oneDayLink.title,
        "events": try controller.getSingleDayFestivals()
    ]

    try response.render("event_list.stencil", context: merge(context)).end()
}

let port = portFromEnv() ?? 8080
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
