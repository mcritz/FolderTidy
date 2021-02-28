import Foundation

// TODO: Tool should be more configuration based. Too many hardcoded values.

let homeURL = FileManager.default.homeDirectoryForCurrentUser

// FIXME: not localized
let downloadsURL = homeURL.appendingPathComponent("Downloads", isDirectory: true)

let allFileURLs = try FileManager
    .default
    .contentsOfDirectory(at: downloadsURL,
                    includingPropertiesForKeys: [.isApplicationKey],
                    options: .skipsPackageDescendants)

/// Error cases
enum TidyError: Error {
    case invalidParameter, failedToMoveFile, failedToDeleteFile
    var localizedDescription: String {
        get {
            switch self {
            case .invalidParameter:
                return NSLocalizedString("Did not include a valid url or path extension", comment: "")
            case .failedToMoveFile:
                return NSLocalizedString("Couldn’t move file", comment: "")
            case .failedToDeleteFile:
                return NSLocalizedString("Couldn’t delete file", comment: "")
            }
        }
    }
}

/// Filters files
/// - Parameter urls: urls for filtering
/// - Parameter pathExtensions: extensions to match
func filterFiles(at urls: [URL], with pathExtensions: [String]) throws -> [URL] {
    guard urls.count > 0
        && pathExtensions.count > 0 else {
            throw TidyError.invalidParameter
    }
    return pathExtensions.flatMap { pathx in
        urls.filter { $0.pathExtension == pathx }
    }
}

/// Moves files
/// - Parameter urls: urls for candidate files
/// - Parameter pathExtensions: extensions, like `jpg` that files must have to be moved
/// - Parameter directory: destination
func moveFiles(at urls: [URL], with pathExtensions: [String], to directory: URL) throws {
    let matches = try filterFiles(at: urls, with: pathExtensions)
    for fileURL in matches {
        let fileName = fileURL.lastPathComponent
        let destinationURL = directory.appendingPathComponent(fileName)
        do {
            try FileManager.default.moveItem(at: fileURL,
                                             to: destinationURL)
        } catch {
            print(error.localizedDescription)
            throw TidyError.failedToMoveFile
        }
    }
}

/// Deletes files
/// - Parameter urls: urls for candidate files
/// - Parameter pathExtensions: extensions, like `zip` that files must have to be deleted
func deleteFiles(at urls: [URL], with pathExtensions: [String]) throws {
    let matches = try filterFiles(at: urls, with: pathExtensions)
    for fileURL in matches {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {
            throw TidyError.failedToDeleteFile
        }
    }
}

// TODO: Configuration points
let applicationsURL = URL(fileURLWithPath: "/Applications", isDirectory: true)

do {
    try moveFiles(at: allFileURLs, with: ["app"], to: applicationsURL)
} catch {
    print(error.localizedDescription)
}

do {
    try deleteFiles(at: allFileURLs, with: [
        "download", // aborted downloads
        "dmg", // disk images, typically from app installs
        "ics", // iCal calendar invites
        "pkg", // macOS app installer packages
        "vcs", // not-iCal calendar invites
        "xip", // fancy compressed files, like Xcode betas
        "zip", // standard compressed files
        "tar.gz", // ye olde compression format
        "tar", // ye olde compression, part the second
        "msi", // Windows installers!?!?!???,
        "exe", // Windows executables
    ])
} catch {
    print(error.localizedDescription)
}
