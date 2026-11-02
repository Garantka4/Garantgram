load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "SGRegDate",
    module_name = "SGRegDate",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//Garantgram/SGRegDateScheme:SGRegDateScheme",
        "//Garantgram/SGSimpleSettings:SGSimpleSettings",
        "//Garantgram/SGAPI:SGAPI",
        "//Garantgram/SGAPIToken:SGAPIToken",
        "//Garantgram/SGDeviceToken:SGDeviceToken",
        "//Garantgram/SGStrings:SGStrings",

        "//submodules/AccountContext:AccountContext",
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//submodules/TelegramPresentationData:TelegramPresentationData",
    ],
    visibility = [
        "//visibility:public",
    ],
)