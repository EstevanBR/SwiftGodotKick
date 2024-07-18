import Foundation

struct ChangeDirectoryError: Swift.Error, LocalizedError {
    let path: String

    var errorDescription: String? {
        "Could not change directory to: \(path)"
    }

    var recoverySuggestion: String? {
        switch FileManager().directoryExists(atPath: path) {
            case (false, false):
                "\(path) does not exist."
            case (true, false):
                "\(path) is a file, not a directory. Please use a valid path to an existing directory."
            case (false, true):
                fatalError("\(path) not exist, but is a directory, this should be impossible.")
            case (true, true):
                fatalError("Directory exists at \(path) this should not have raised an error.")
        }
    }
}
