import Foundation
import Kitura
import HeliumLogger
import KituraStencil

func getPortFromEnv() -> Int? {
    guard let envPort = ProcessInfo.processInfo.environment["PORT"] else { return nil }
    return Int(envPort)
}

HeliumLogger.use()

let router = Router()

router.all("/", middleware: StaticFileServer())
router.add(templateEngine: StencilTemplateEngine())

let mainLinks : [String : Any] = [
    "links" : [
        Link(title: "Cancelled Events", path: "/cancelled"),
        Link(title: "Multi-day Festivals", path: "/multiday_fest"),
        Link(title: "One day Festivals", path: "/oneday_fest"),
    ]
]

router.get("/") { request, response, next in
    defer { next() }

    let context = mainLinks
    try response.render("home.stencil", context: context).end()
}

let port = getPortFromEnv() ?? 8080
Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
