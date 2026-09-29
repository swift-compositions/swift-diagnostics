import Source
import Testing
import Text

@testable import Diagnostics

extension Diagnostics.Parser {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension Diagnostics.Parser.Test.Unit {
    @Test
    func `Single error line yields one record with expected fields`() {
        let stderr = "/path/to/File.swift:12:5: error: cannot find 'foo' in scope"
        let records = Diagnostics.Parser.parse(stderr: stderr)

        try? #require(records.count == 1)
        guard let record = records.first else { return }
        #expect(record.severity == .error)
        #expect(record.identifier == "swift_build_diagnostic")
        #expect(record.message == "cannot find 'foo' in scope")
        #expect(record.location.fileID == "/path/to/File.swift")
        #expect(record.location.filePath == "/path/to/File.swift")
        #expect(record.location.line.underlying == 12)
    }

    @Test
    func `Multiple lines mixed severities preserve order and counts`() {
        let stderr = """
            /A.swift:1:1: error: bad
            /B.swift:2:2: warning: meh
            /C.swift:3:3: note: fyi
            /D.swift:4:4: remark: hint
            """
        let records = Diagnostics.Parser.parse(stderr: stderr)
        #expect(records.count == 4)
        #expect(records.map(\.severity) == [.error, .warning, .note, .remark])
        #expect(records.map(\.message) == ["bad", "meh", "fyi", "hint"])
    }

    @Test
    func `Severity-keyword mapper covers all four wire keywords`() {
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "error") == .error)
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "warning") == .warning)
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "note") == .note)
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "remark") == .remark)
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "unknown") == nil)
        #expect(Diagnostics.Parser.Line.severity(forKeyword: "") == nil)
    }
}

extension Diagnostics.Parser.Test.`Edge Case` {
    @Test
    func `Empty stderr yields no records`() {
        let records = Diagnostics.Parser.parse(stderr: "")
        #expect(records.isEmpty)
    }

    @Test
    func `Malformed lines are silently skipped`() {
        let stderr = """
            Building swift-foo
            /Real.swift:7:3: warning: shadowed
            not a diagnostic
            /BadColumn.swift:9:NotANumber: error: nope
            Compiling File.swift
            /Unknown.swift:1:1: bogus: not a real severity
            """
        let records = Diagnostics.Parser.parse(stderr: stderr)

        try? #require(records.count == 1)
        guard let record = records.first else { return }
        #expect(record.severity == .warning)
        #expect(record.message == "shadowed")
    }

    @Test
    func `CRLF line endings leave no carriage-return residue`() {
        let stderr = "/A.swift:1:1: error: bad\r\n"
        let records = Diagnostics.Parser.parse(stderr: stderr)

        try? #require(records.count == 1)
        guard let record = records.first else { return }
        #expect(record.message == "bad")
    }
}
