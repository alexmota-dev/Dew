import Foundation
import GRPC
import NIO
import SwiftProtobuf

class GreeterProvider: Hello_GreeterProvider {
    func sayHello(
        request: Hello_HelloRequest,
        context: StatusOnlyCallContext
    ) -> EventLoopFuture<Hello_HelloReply> {
        let received = request.name
        print("📩 Mensagem recebida do cliente: \(received)")

        let reply = Hello_HelloReply.with {
            $0.message = "✅ Mensagem recebida: \(received)"
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

let port = 50051

func initialServer() {
    let server = Server.insecure(group: group)
        .withServiceProviders([GreeterProvider()])

    do {
        let channel = try server.bind(host: "localhost", port: port).wait()
        print("🟢 Servidor gRPC rodando em localhost:\(port)")
        print("📬 Aguardando mensagens... \n Pressione [Enter] para encerrar o servidor.")

        // Espera entrada do usuário
        _ = readLine()

        try channel.close().wait()
        try group.syncShutdownGracefully()

        print("👋 Servidor encerrado com sucesso.")
        exit(0)
    } catch {
        print("❌ Erro ao iniciar servidor: \(error)")
        exit(1)
    }
}

func initialClient() {
    print("🟢 Cliente gRPC iniciado...")
    let channel = ClientConnection.insecure(group: group)
        .connect(host: "localhost", port: port)

    let client = Hello_GreeterNIOClient(channel: channel)

    func sendMessage() {
        print("✉️  Digite uma mensagem para enviar ao servidor:")
        guard let text = readLine(), !text.isEmpty else {
            print("⚠️ Mensagem vazia. Tente novamente.")
            return sendMessage()
        }

        var request = Hello_HelloRequest()
        request.name = text

        let call = client.sayHello(request)

        call.response.whenComplete { result in
            switch result {
            case .success(let reply):
                print("📨 Resposta do servidor: \(reply.message)")
                print("Deseja enviar outra mensagem? (s/n)")
                if let resposta = readLine(), resposta.lowercased() == "s" {
                    sendMessage()
                } else {
                    print("👋 Cliente encerrado com sucesso.")
                    exit(0)
                }
            case .failure(let error):
                print("❌ Erro ao enviar mensagem: \(error)")
                exit(1)
            }
        }
    }

    sendMessage()
    RunLoop.current.run()
}

func showMenu() {
    print("""
    Escolha uma opção:
    0 - Rodar como servidor gRPC
    1 - Rodar como cliente gRPC
    """)

    guard let escolha = readLine(), let opcao = Int(escolha) else {
        print("❌ Entrada inválida. Finalizando.")
        exit(1)
    }

    switch opcao {
    case 0:
        initialServer()
    case 1:
        initialClient()
    default:
        print("❌ Opção inválida. Use 0 ou 1.")
        exit(1)
    }
}

showMenu()

