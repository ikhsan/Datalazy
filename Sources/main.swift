import HTTPServer

let log = LogMiddleware()

let router = BasicRouter { route in

  route.get("/") { request in
    return Response(body: "Hello from Zewo!")
  }

}

let server = try Server(port: 8080, middleware: [log], responder: router)
try server.start()
