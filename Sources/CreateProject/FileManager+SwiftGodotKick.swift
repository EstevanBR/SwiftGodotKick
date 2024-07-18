import Foundation

extension FileManager {
    struct FileAlreadyExistsError: Swift.Error, LocalizedError {
        let path: String
        var errorDescription: String? {
            "Tried to create file at \(path) but the file already exists"
        }
    }

    func createFile(atPath path: String, contents data: Data, replace: Bool) throws {
        if replace == false, FileManager().fileExists(atPath: path) {
            throw FileAlreadyExistsError(path: path)
        }
        createFile(atPath: path, contents: data)
    }

    func directoryExists(atPath path: String) -> (exists: Bool, isDirectory: Bool) {
        var isDirectory = ObjCBool(booleanLiteral: false)

        return (exists: fileExists(atPath: path, isDirectory: &isDirectory), isDirectory: isDirectory.boolValue)
    }
}
