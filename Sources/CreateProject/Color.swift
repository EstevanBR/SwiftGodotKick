import class Foundation.ProcessInfo

enum Color: String {
    case reset = "\u{001B}[0;0m"
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"

    case bgBlack = "\u{001B}[0;40m"
    case bgRed = "\u{001B}[0;41m"
    case bgGreen = "\u{001B}[0;42m"
    case bgYellow = "\u{001B}[0;43m"
    case bgBlue = "\u{001B}[0;44m"
    case bgMagenta = "\u{001B}[0;45m"
    case bgCyan = "\u{001B}[0;46m"
    case bgWhite = "\u{001B}[0;47m"

    static func +(color: Color, text: String) -> String {
        guard UserChoice.shouldColorizeOutput else {
            return text
        }
        return color.rawValue + text + Color.reset.rawValue
    }
}
