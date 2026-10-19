// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ContrasDush",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "ContrasDush", targets: ["ContrasDush"])
    ],
    targets: [
        .executableTarget(
            name: "ContrasDush",
            path: "ContrasDush"
        )
    ]
)