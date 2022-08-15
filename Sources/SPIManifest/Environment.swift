// Copyright 2020-2021 Dave Verwer, Sven A. Schmidt, and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation


struct Environment {
    var fileManager: FileManager
}


extension Environment {
    static let live: Self = .init(
        fileManager: .live
    )
}


// MARK: FileManager

struct FileManager {
    var contents: (_ atPath: String) -> Data?
    var createDirectory: (_ path: String,
                          _ withIntermediateDirectories: Bool,
                          _ attributes: [FileAttributeKey : Any]?) throws -> Void
    var createFile: (_ atPath: String,
                     _ contents: Data?,
                     _ attributes: [FileAttributeKey : Any]?) -> Bool
    var fileExists: (_ path: String) -> Bool
    var removeItem: (_ path: String) throws -> Void
    var temporaryDirectory: () -> URL

    static let live: Self = .init(
        contents: Foundation.FileManager.default.contents(atPath:),
        createDirectory: Foundation.FileManager.default
            .createDirectory(atPath:withIntermediateDirectories:attributes:),
        createFile: Foundation.FileManager.default.createFile(atPath:contents:attributes:),
        fileExists: Foundation.FileManager.default.fileExists(atPath:),
        removeItem: Foundation.FileManager.default.removeItem(atPath:),
        temporaryDirectory: { Foundation.FileManager.default.temporaryDirectory }
    )
}


// Convenience functions to provide argument labels for function vars
extension FileManager {
    func contents(atPath path: String) -> Data? { contents(path) }
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        try createDirectory(path, createIntermediates, attributes)
    }
    func fileExists(atPath path: String) -> Bool { fileExists(path) }
}


// MARK: - Current

#if DEBUG
var Current: Environment = .live
#else
let Current: Environment = .live
#endif
