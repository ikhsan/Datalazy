import Foundation

struct EventLinks {
    static let all = Link(title: "All Events", path: "/event/all")
    static let cancelled = Link(title: "Cancelled Events", path: "/event/cancelled")
    static let multiDay = Link(title: "Multi-day Festivals", path: "/event/multiday_fest")
    static let oneDay = Link(title: "One day Festivals", path: "/event/oneday_fest")
    static let futureOnsale = Link(title: "Future Onsale", path: "/event/future_onsale")

    static let links: [Link] = [ all, cancelled, multiDay, oneDay, futureOnsale ]
}

struct ArtistLinks {
    static let all = Link(title: "Artists", path: "/artist/all")

    static let links: [Link] = [ all ]
}

func merge(_ localContext: [String : Any]) -> [String : Any] {
    var context : [String : Any] = [
        "links" : EventLinks.links + ArtistLinks.links
    ]
    localContext.forEach { context.updateValue($1, forKey: $0) }
    return context
}
