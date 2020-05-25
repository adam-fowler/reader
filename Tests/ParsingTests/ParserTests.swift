import XCTest
@testable import Parsing

final class ParserTests: XCTestCase {
    func testCharacter() {
        var parser = Parser("TestString")
        XCTAssertEqual(try parser.character(), "T")
        XCTAssertEqual(try parser.character(), "e")
    }

    func testSubstring() {
        var parser = Parser("TestString")
        XCTAssertThrowsError(try parser.read(count: 23))
        XCTAssertEqual(try parser.read(count: 3).string, "Tes")
        XCTAssertEqual(try parser.read(count: 5).string, "tStri")
        XCTAssertThrowsError(try parser.read(count: 3))
        XCTAssertNoThrow(try parser.read(count: 2))
    }

    func testReadCharacter() {
        var parser = Parser("TestString")
        XCTAssertNoThrow(try parser.read("T"))
        XCTAssertNoThrow(try parser.read("e"))
        XCTAssertEqual(try parser.read("e"), false)
    }

    func testReadUntilCharacter() throws {
        var parser = Parser("TestString")
        XCTAssertEqual(try parser.read(until:"S").string, "Test")
        XCTAssertEqual(try parser.read(until:"n").string, "Stri")
        XCTAssertThrowsError(try parser.read(until:"!"))
    }

    func testReadUntilCharacterSet() throws {
        var parser = Parser("TestString")
        XCTAssertEqual(try parser.read(until:Set("Sr")).string, "Test")
        XCTAssertEqual(try parser.read(until:Set("abcdefg")).string, "Strin")
    }

    func testReadUntilString() throws {
        var parser = Parser("<!-- check for -comment end -->")
        XCTAssertEqual(try parser.read(untilString:"-->").string, "<!-- check for -comment end ")
        XCTAssertTrue(try parser.read("-->"))
    }

    func testReadWhileCharacter() throws {
        var parser = Parser("122333")
        XCTAssertEqual(parser.read(while:"1"), 1)
        XCTAssertEqual(parser.read(while:"2"), 2)
        XCTAssertEqual(parser.read(while:"3"), 3)
    }

    func testReadWhileCharacterSet() throws {
        var parser = Parser("aabbcdd836de")
        XCTAssertEqual(parser.read(while:Set("abcdef")).string, "aabbcdd")
        XCTAssertEqual(parser.read(while:Set("123456789")).string, "836")
        XCTAssertEqual(parser.read(while:Set("abcdef")).string, "de")
    }

    func testRetreat() throws {
        var parser = Parser("abcdef")
        XCTAssertThrowsError(try parser.retreat())
        _ = try parser.read(count: 4)
        try parser.retreat(by: 3)
        XCTAssertEqual(try parser.read(count: 4).string, "bcde")
    }
    
    func testCopy() throws {
        var parser = Parser("abcdef")
        XCTAssertEqual(try parser.read(count: 3).string, "abc")
        var reader2 = parser
        XCTAssertEqual(try parser.read(count: 3).string, "def")
        XCTAssertEqual(try reader2.read(count: 3).string, "def")
    }
    
  /*  func testScan() throws {
        var parser = Parser("\"this\" = \"that\"")
        let result = try parser.scan(format: "\"%%\" = \"%%\"")
        XCTAssertEqual(result[0], "this")
        XCTAssertEqual(result[1], "that")

        var reader2 = Parser("this = that")
        let result2 = try reader2.scan(format: "%% = %%")
        XCTAssertEqual(result2[0], "this")
        XCTAssertEqual(result2[1], "that")
    }
    
    func testScanError() throws {
        var reader2 = Parser("this == that")
        XCTAssertThrowsError(try reader2.scan(format: "%% = %%"))
    }*/
    
    
    static var allTests = [
        ("testCharacter", testCharacter),
        ("testSubstring", testSubstring),
        ("testReadCharacter", testReadCharacter),
        ("testReadUntilCharacter", testReadUntilCharacter),
        ("testReadUntilCharacterSet", testReadUntilCharacterSet),
        ("testReadUntilString", testReadUntilString),
        ("testReadWhileCharacter", testReadWhileCharacter),
        ("testReadWhileCharacterSet", testReadWhileCharacterSet),
        ("testRetreat", testRetreat),
        ("testCopy", testCopy),
 /*       ("testScan", testScan),
        ("testScanError", testScanError),*/
    ]
}

extension Character {
    var isAlphaNumeric: Bool {
        return isLetter || isNumber
    }
}
