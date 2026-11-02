load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "SGAPI",
    module_name = "SGAPI",
    srcs = glob([
		"Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/SSignalKit/SwiftSignalKit:SwiftSignalKit",
        "//Garantgram/SGLogging:SGLogging",
        "//Garantgram/SGWebAppExtensions:SGWebAppExtensions",
        "//Garantgram/SGSimpleSettings:SGSimpleSettings",
        "//Garantgram/SGWebSettingsScheme:SGWebSettingsScheme",
        "//Garantgram/SGRegDateScheme:SGRegDateScheme",
        "//Garantgram/SGRequests:SGRequests",
        "//Garantgram/SGConfig:SGConfig"
    ],
    visibility = [
        "//visibility:public",
    ],
)
