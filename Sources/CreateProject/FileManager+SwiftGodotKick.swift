import Foundation

extension FileManager {
    struct FileAlreadyExistsError: Swift.Error, LocalizedError {
        let path: String
        var errorDescription: String? {
            "Tried to create file at \(path) but the file already exists"
        }
    }

    func createFile(atPath path: String, contents data: Data, replace: Bool) throws {
        if replace == false, fileManager.fileExists(atPath: path) {
            throw FileAlreadyExistsError(path: path)
        }
        createFile(atPath: path, contents: data)
    }
}
