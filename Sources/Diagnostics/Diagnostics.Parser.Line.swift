internal import Source

extension Diagnostics.Parser {

    internal enum Line {
    }
}

extension Diagnostics.Parser.Line {

    internal static func parse(_ line: Swift.String) -> Diagnostic.Record? {
        let drive = drive(of: line)
        let parts = line.dropFirst(drive.count).split(separator: ":", maxSplits: 4, omittingEmptySubsequences: false)
        guard parts.count == 5 else { return nil }
        let path = drive + Swift.String(parts[0])
        guard let lineNumber = Swift.Int(parts[1]),
            let columnNumber = Swift.Int(parts[2])
        else { return nil }
        let severityString = parts[3].trimmingPrefixWhitespace()
        let message = parts[4].trimmingPrefixWhitespace()
        guard let severity = severity(forKeyword: severityString) else { return nil }
        return Diagnostic.Record(
            location: Source.Location(
                fileID: path,
                filePath: path,
                line: lineNumber,
                column: columnNumber
            ),
            severity: severity,
            identifier: "swift_build_diagnostic",
            message: message
        )
    }

    internal static func drive(of line: Swift.String) -> Swift.String {
        let prefix = Swift.Array(line.utf8.prefix(3))
        return prefix.count == 3
            && ((0x41...0x5A).contains(prefix[0]) || (0x61...0x7A).contains(prefix[0]))
            && prefix[1] == 0x3A
            && (prefix[2] == 0x5C || prefix[2] == 0x2F)
            ? Swift.String(line.prefix(2)) : ""
    }

    internal static func severity(forKeyword keyword: Swift.String) -> Diagnostic.Severity? {
        switch keyword {
        case "error": return .error
        case "warning": return .warning
        case "note": return .note
        case "remark": return .remark
        default: return nil
        }
    }
}

extension Swift.Substring {
    fileprivate func trimmingPrefixWhitespace() -> Swift.String {
        Swift.String(self.drop(while: { $0 == " " || $0 == "\t" }))
    }
}
