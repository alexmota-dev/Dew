import Foundation
import GRPC
import NIO
import SwiftProtobuf

class GreeterProvider: Hello_GreeterProvider {
    func sayHello(
        request: Hello_HelloRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Hello_HelloReply> {
        let reply = Hello_HelloReply.with {
            $0.message = "Olá, \(request.name)"
        }
        return context.eventLoop.makeSucceededFuture(reply)
    }

    var interceptors: Hello_GreeterServerInterceptorFactoryProtocol? {
        return nil
    }
}

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
    try? group.syncShutdownGracefully()
}

let server = Server.insecure(group: group)
    .withServiceProviders([GreeterProvider()])

do {
    _ = try server.bind(host: "localhost", port: 50051).wait()
    print("🟢 Servidor rodando em localhost:50051")

    // Cliente
    let channel = ClientConnection.insecure(group: group)
        .connect(host: "localhost", port: 50051)

    let client = Hello_GreeterNIOClient(channel: channel)
    var request = Hello_HelloRequest()
    request.name = "Alek"

    let call = client.sayHello(request)

    call.response.whenComplete { result in
        switch result {
        case .success(let reply):
            print("🔵 Resposta do servidor: \(reply.message)")
        case .failure(let error):
            print("❌ Erro: \(error)")
        }
        exit(0)
    }

    RunLoop.current.run()

} catch {
    print("❌ Erro ao iniciar servidor: \(error)")
}

