import Foundation

struct EventLinks {
    static let all = Link(title: "All Events", path: "/all")
    static let cancelled = Link(title: "Cancelled Events", path: "/cancelled")
    static let multiDay = Link(title: "Multi-day Festivals", path: "/multiday_fest")
    static let oneDay = Link(title: "One day Festivals", path: "/oneday_fest")

    static let links: [Link] = [ all, cancelled, multiDay, oneDay ]
}

func merge(_ localContext: [String : Any]) -> [String : Any] {
    var context : [String : Any] = [
        "links" : EventLinks.links
    ]
    localContext.forEach { context.updateValue($1, forKey: $0) }
    return context
}
