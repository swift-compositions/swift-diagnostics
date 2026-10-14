extension Diagnostics {

    public enum Parser: Swift::Sendable {
    }
}

extension Diagnostics.Parser {

    public static func parse(stderr text: Swift::String) -> [Diagnostic.Record] {

        var records: [Diagnostic.Record] = []
        for byteLine in text.utf8.split(separator: 0x0A, omittingEmptySubsequences: true) {
            var byteLine = byteLine
            if byteLine.last == 0x0D {
                byteLine.removeLast()
            }
            guard let record = Line.parse(Swift::String(decoding: byteLine, as: Swift::UTF8.self))
            else { continue }
            records.append(record)
        }
        return records
    }
}
