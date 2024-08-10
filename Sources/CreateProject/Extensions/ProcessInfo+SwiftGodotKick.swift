import class Foundation.ProcessInfo

extension ProcessInfo {
    func string(for argument: UserChoice.Argument) -> String? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let firstIndex = arguments.firstIndex(of: argument.rawValue) else {
            return nil
        }

        guard arguments.indices.contains(firstIndex + 1) else {
            return nil
        }

        return arguments[firstIndex + 1]
    }

    func bool(for argument: UserChoice.Argument) -> Bool? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let firstIndex = arguments.firstIndex(of: argument.rawValue) else {
            return nil
        }

        guard arguments.indices.contains(firstIndex + 1) else {
            return nil
        }

        return Bool(arguments[firstIndex + 1])
    }
}
