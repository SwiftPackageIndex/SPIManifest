#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import SPIManifest


@main
enum Validator {
    static func main() {
        guard CommandLine.arguments.count == 2,
              let path = CommandLine.arguments.last else {
            print("Usage: spi-manifest-validate <.spi.yml file>")
            exit(1)
        }

        do {
            _ = try SPIManifest.Manifest.load(at: path)
        } catch {
            print("🔴 \(error)")
            exit(2)
        }

        print("✅ The file is valid.")
    }
}
