// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyAppDependencies",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "MyAppDependencies",
            targets: ["MyAppDependencies"]
        ),
    ],
    dependencies: [
 
    ],
    targets: [
        .target(
            name: "MyAppDependencies",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "MyAppDependenciesTests",
            dependencies: ["MyAppDependencies"]
        ),
    ]
)
