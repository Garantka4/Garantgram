load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

filegroup(
    name = "SGPayWallAssets",
    srcs = glob(["Images.xcassets/**"]),
    visibility = ["//visibility:public"],
)

swift_library(
    name = "SGPayWall",
    module_name = "SGPayWall",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//Garantgram/SGIAP:SGIAP",
        "//Garantgram/SGLogging:SGLogging",
        "//Garantgram/SGSimpleSettings:SGSimpleSettings",
        "//Garantgram/SGSwiftUI:SGSwiftUI",
        "//Garantgram/SGStrings:SGStrings",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
    ],
    visibility = [
        "//visibility:public",
    ],
)
