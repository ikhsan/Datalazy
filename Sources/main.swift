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

// MARK: Main app

HeliumLogger.use()

let router = Router()
router.all("/", middleware: StaticFileServer())
router.add(templateEngine: StencilTemplateEngine())

let controller = EventController()

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

let port = portFromEnv() ?? 8080
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
