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


