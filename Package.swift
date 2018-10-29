// swift-tools-version:4.1
import PackageDescription

_ = Package(name: "Bluetooth",
            products: [
                .library(
                    name: "Bluetooth",
                    targets: ["Bluetooth"]
                )
            ],
            targets: [
                .target(name: "Bluetooth", path: "./Sources"),
                .testTarget(name: "BluetoothTests", dependencies: ["Bluetooth"])
            ],
            swiftLanguageVersions: [4])
