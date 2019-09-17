/*
 As a person with a Mac
 I want a way to move all Applications from the ~/Downloads folder to the /Applications folder
 So I don’t have to do repedative tasks
 */

import Foundation

// 1. Get ~/Downloads folder
let homeURL = FileManager.default.homeDirectoryForCurrentUser

let downloadsURL = homeURL.appendingPathComponent("Downloads", isDirectory: true)

// 2. Find all the files
let allFileURLs = try FileManager
    .default
    .contentsOfDirectory(at: downloadsURL,
                    includingPropertiesForKeys: [.isApplicationKey],
                    options: .skipsPackageDescendants)

enum TidyError: Error {
    case invalidParameter, failedToMoveFile, failedToDeleteFile
    var description: String {
        get {
            switch self {
            case .invalidParameter:
                return "Did not include a valid url or path extension"
            case .failedToMoveFile:
                return "Couldn’t move file"
            case .failedToDeleteFile:
                return "Couldn’t delete file"
            }
        }
    }
}

func filterFiles(at urls: [URL], with pathExtensions: [String]) throws -> [URL] {
    guard urls.count > 0
        && pathExtensions.count > 0 else {
            throw TidyError.invalidParameter
    }
    var matchedURLs = [URL]()
    for pathx in pathExtensions {
        let newMatchedURLs = urls.filter { url in
            url.pathExtension == pathx
        }
        matchedURLs.append(contentsOf: newMatchedURLs)
    }
    return matchedURLs
}

func moveFiles(at urls: [URL], with pathExtensions: [String], to directory: URL) throws {
    let matches = try filterFiles(at: urls, with: pathExtensions)
    for fileURL in matches {
        let fileName = fileURL.lastPathComponent
        let destinationURL = applicationsURL.appendingPathComponent(fileName)
        do {
            try FileManager.default.moveItem(at: fileURL,
                                         to: destinationURL)
        } catch {
            print("Could not move \(fileName)")
            print(error.localizedDescription)
            throw TidyError.failedToMoveFile
        }
    }
}

func deleteFiles(at urls: [URL], with pathExtensions: [String]) throws {
    let matches = try filterFiles(at: urls, with: pathExtensions)
    for fileURL in matches {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {
            print("Could not remove \(fileURL.lastPathComponent)")
            print(error.localizedDescription)
            throw TidyError.failedToDeleteFile
        }
    }
}


// 

let applicationsURL = URL(fileURLWithPath: "/Applications",
isDirectory: true)

try moveFiles(at: allFileURLs, with: ["app"], to: applicationsURL)

try deleteFiles(at: allFileURLs, with: [
    "dmg",
    "ics",
    "pkg",
    "vcs",
    "xip",
    "zip",
])
