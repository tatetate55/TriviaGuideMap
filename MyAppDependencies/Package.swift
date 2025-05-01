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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.21.0"),
    ],
    targets: [
        .target(
            name: "MyAppDependencies",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // 👆 これだけでOK！
            ]
        ),
        .testTarget(
            name: "MyAppDependenciesTests",
            dependencies: ["MyAppDependencies"]
        ),
    ]
)
