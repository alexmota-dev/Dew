# Como criar uma aplicação gRPC simples usando Objective-C

## O que vamos fazer ?
### Um servidor e um cliente de terminal que trocam uma simples mensagem (HelloRequest e HelloReply) usando gRPC.

### Usaremos CocoaPods para instalar o gRPC (baseado na [documentacao oficial do grpc](https://grpc.io/docs/languages/objective-c/quickstart/))

### A geração dos arquivos .pbobjc.h/.m e .grpc.pbobjc.h/.m será feita automaticamente a partir do .proto.

## 1. Pré-requisitos

### ✅ macOS 15.2
### ✅ Xcode 16.1 instalado (confira: xcodebuild -version)
### ✅ CocoaPods instalado
### ✅ Ruby Instalado
### ✅ Homebrew Instalado

## 1.1 Instalar o Homebrew:
### 1.1.1 Execute o seguinte comando no terminal: 
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
### 1.1.2 Depois adicione o Homebrew ao seu terminal (Intel ou ARM, depende do resultado de uname -m):
```bash
# Para processadores Intel:
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"

# Para processadores Apple Silicon (M1, M2, M3):
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 1.2 Instalar o ruby:
### 1.2.1 Verifique a versao do seu ruby

```bash
ruby -v
```
### Caso a versao seja inferior a versao 3.X.X ou caso nao tenha o ruby instalado, execute o script

```bash
brew install ruby
```

### Agora verifique novamente a versao do ruby, caso ainda seja a mesma versao antiga, e necessario dizer para o sistema usar a versao mais recent.
### Nesse caso execute o script

```bash
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

## 1.3 Instalar o cocoapods:
### 1.3.1 Execute o script

```bash
sudo gem install cocoapods
```

## 2. Crie um projeto no xcode

### Abra o Xcode.

### Crie um novo projeto ➔ macOS App ➔ "Command Line Tool" (para ser mais simples).

### Nomeie como HelloGrpcObjC.

### Escolha Objective-C como linguagem.


## 3.Criar e executar podfile

### Dentro desse projeto crie um arquivo Podfile:

nano Podfile

### Adicione o codigo abaixo ao arquivo e apos isso faca ctrl+x, y e Enter.

platform :macos, '11.0'

target 'HelloGrpcObjC' do
  use_frameworks!
  
  pod 'gRPC-ProtoRPC'
  pod 'Protobuf'
end

### Agora vamos fazer a isntalacao do podfile

pod install

### Isso deve gerar um .xcworkspace, vamos abrir esse cara no xocde

open HelloGrpcObjC.xcworkspace

## 3. Crie o seu arquivo .proto

Crie uma pasta no projeto chamada Protos/ e adicione um arquivo chamado hello.proto:

mkdir protos
nano hello.proto

Adicione o seguinte codigo ao hello.proto e apos isso faca ctrl+x, y e Enter.

syntax = "proto3";

package hello;

service Greeter {
  rpc SayHello (HelloRequest) returns (HelloReply);
}

message HelloRequest {
  string name = 1;
}

message HelloReply {
  string message = 1;
}

## 4. Configure a geração automática do .proto

No Xcode:

    Clique no projeto → vá em Build Phases → + New Run Script Phase.

    Renomei o Script para Generate Protobuf Files

    Arraste o script para ficar antes de Compile Sources.

    No novo Run Script, cole:

# Define onde estão os arquivos .proto
PROTO_ROOT="${SRCROOT}/Protos"

# Define onde gerar os arquivos gerados
OUTPUT_DIR="${SRCROOT}/Generated"

# Garante que a pasta Generated existe
mkdir -p "${OUTPUT_DIR}"

# Executa o protoc usando as opções corretas
find "${PROTO_ROOT}" -name "*.proto" | while read proto; do
  protoc \
    --proto_path="${PROTO_ROOT}" \
    --objc_out="${OUTPUT_DIR}" \
    --objc-grpc_out="${OUTPUT_DIR}" \
    "$proto"
done


## 5. Verificar se o proto buffer esta instalado:

### 5.1 Execute no terminal:

protoc --version

### Caso apareca algo como

libprotoc 3.21.12

### Significa que voce tem o protoc instalado e podemos seguir para o passo 6, caso contrario execute:

brew install protobuf

### Entao verifique novamente se a versao do protoc para garantir que ele foi instalado.

## 6. Vamo criar o script para rodar o projeto e adicionar no xoode



## 9. Reestrutura o arquivo main.m que ja deve existir no projeto (foi criado pelo xcode quando voce criou o projeto)

#import <Foundation/Foundation.h>
#import "Hello.pbrpcobjc.h"

@interface Greeter : Hello_Greeter
@end

@implementation Greeter

- (void)sayHelloWithRequest:(Hello_HelloRequest *)request handler:(void(^)(Hello_HelloReply *_Nullable response, NSError *_Nullable error))handler {
    Hello_HelloReply *reply = [Hello_HelloReply message];
    reply.message = [NSString stringWithFormat:@"Olá, %@!", request.name];
    handler(reply, nil);
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Configurar o servidor
        GRPCMutableCallOptions *options = [[GRPCMutableCallOptions alloc] init];
        options.transport = GRPCDefaultTransportImplList.core_insecure;
        
        NSString *address = @"localhost:50051";
        
        Greeter *greeter = [[Greeter alloc] init];
        GRPCServer *server = [[GRPCServer alloc] initWithHandlers:@{@"hello.Greeter/SayHello": greeter}];
        [server startWithHost:@"0.0.0.0" port:50051];

        NSLog(@"Servidor rodando em %@", address);
        
        // Configurar o cliente
        Hello_GreeterService *client = [Hello_GreeterService serviceWithHost:address callOptions:options];
        Hello_HelloRequest *request = [Hello_HelloRequest message];
        request.name = @"Alek";

        [client sayHelloWithRequest:request handler:^(Hello_HelloReply * _Nullable response, NSError * _Nullable error) {
            if (response) {
                NSLog(@"Resposta do servidor: %@", response.message);
            } else {
                NSLog(@"Erro: %@", error);
            }
            exit(0);
        }];
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}

## 6. Passo 6
