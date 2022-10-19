import Foundation

import PackagePlugin


@main
struct CodeGenerator: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        if arguments.contains("--help") || arguments.contains("-h") {
            print("Run")
            print("  swift package plugin validate-spi-manifest")
            print("to validate this package's .spi.yml file")
            return
        }

        let manifestPath = context.package.directory.appending([".spi.yml"])

        let validator = try context.tool(named: "validate-spi-manifest")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: validator.path.string)
        process.arguments = [manifestPath.string]

        try process.run()
        process.waitUntilExit()
    }
}
