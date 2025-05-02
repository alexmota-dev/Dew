// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "HelloGrpcSwiftSPM",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.25.0")
    ],
    targets: [
        .executableTarget(
            name: "HelloGrpcSwiftSPM",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
            ],
            path: "Sources"
        )
    ]
)

