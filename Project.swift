import ProjectDescription

let project = Project(
    name: "ImageCache",
    targets: [
        .target(
            name: "ImageCache",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.ImageCache",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["ImageCache/Sources/**"],
            resources: ["ImageCache/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "ImageCacheTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.ImageCacheTests",
            infoPlist: .default,
            sources: ["ImageCache/Tests/**"],
            resources: [],
            dependencies: [.target(name: "ImageCache")]
        ),
    ]
)
