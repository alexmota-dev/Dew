# Create file

# Como criar uma aplicação gRPC simples usando Objective-C (no macOS 11.0.1 com Xcode 12.4)

## O que vamos fazer ?
### Um servidor e um cliente de terminal que trocam uma simples mensagem (HelloRequest e HelloReply) usando gRPC.

### Usaremos CocoaPods para instalar o gRPC (baseado na [documentacao oficial do grpc](https://grpc.io/docs/languages/objective-c/quickstart/))

### A geração dos arquivos .pbobjc.h/.m e .grpc.pbobjc.h/.m será feita automaticamente a partir do .proto.

## 1. Pré-requisitos

### ✅ macOS 11.0.1
### ✅ Xcode 12.4 instalado (confira: xcodebuild -version)
### ✅ CocoaPods instalado

## 1.1 Instalar o cocoapods caso náo tenha instalado:

sudo gem install cocoapods

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

