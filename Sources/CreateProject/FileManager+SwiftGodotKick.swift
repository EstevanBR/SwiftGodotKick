import Foundation

extension FileManager {
    struct FileExistsError: Swift.Error {}

    func createFile(atPath path: String, contents data: Data, replace: Bool) throws {
        if replace == false, fileManager.fileExists(atPath: path) {
            throw FileExistsError()
        }
        createFile(atPath: path, contents: data)
    }
}
