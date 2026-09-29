internal import Source

extension Diagnostics.Parser {

    internal enum Line {
    }
}

extension Diagnostics.Parser.Line {

    internal static func parse(_ line: Swift.String) -> Diagnostic.Record? {
        let parts = line.split(separator: ":", maxSplits: 4, omittingEmptySubsequences: false)
        guard parts.count == 5 else { return nil }
        let path = Swift.String(parts[0])
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
