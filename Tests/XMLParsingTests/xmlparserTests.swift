import XCTest
@testable import XMLParsing

import Foundation
#if os(Linux)
import FoundationXML
#endif


class XMLParserTests: XCTestCase {

    func testValidDeclaration() {
        let xml1 = "<?xml version='1.1' encoding='utf-8' ?>"
        let xml2 = "<?XML version='1.1' encoding='utf-8' ?>"
        let xml3 = "<?xml encoding='utf-8' version='1.1' ?>"
        let xml4 = "<?xml version='1.1' encoding='utf-8'?>"
        let xml5 = "<?xml version='1.1' encoding='UTF-8'?>"
        let parser = SwiftXMLParser()
        XCTAssertNoThrow(try parser.parse(xmlString: xml1))
        XCTAssertNoThrow(try parser.parse(xmlString: xml2))
        XCTAssertNoThrow(try parser.parse(xmlString: xml3))
        XCTAssertNoThrow(try parser.parse(xmlString: xml4))
        XCTAssertNoThrow(try parser.parse(xmlString: xml5))
    }

    func testNoDeclaration() {
        let xml = "<element></element>"
        let parser = SwiftXMLParser()
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }
    
    func testValidElements() {
        let xml1 = "<?xml version='1.1' encoding='utf-8' ?><element />"
        let xml2 = "<?xml version='1.1' encoding='utf-8' ?><element/>"
        let xml3 = "<?xml version='1.1' encoding='utf-8' ?><element></element>"
        let xml4 = "<?xml version='1.1' encoding='utf-8' ?><element><p></p></element>"
        let xml5 = "<?xml version='1.1' encoding='utf-8' ?><element><p/></element>"
        let parser = SwiftXMLParser()
        XCTAssertNoThrow(try parser.parse(xmlString: xml1))
        XCTAssertNoThrow(try parser.parse(xmlString: xml2))
        XCTAssertNoThrow(try parser.parse(xmlString: xml3))
        XCTAssertNoThrow(try parser.parse(xmlString: xml4))
        XCTAssertNoThrow(try parser.parse(xmlString: xml5))
    }
    
    func testInvalidElements() {
        let xml1 = "<element></element1>"
        let xml2 = "<element>"
        let xml3 = "<a><b></a></b>"
        let xml4 = "<a><b></B></a>"
        let parser = SwiftXMLParser()
        XCTAssertThrowsError(try parser.parse(xmlString: xml1))
        XCTAssertThrowsError(try parser.parse(xmlString: xml2))
        XCTAssertThrowsError(try parser.parse(xmlString: xml3))
        XCTAssertThrowsError(try parser.parse(xmlString: xml4))
    }
    
    func testValidElementsWithAttributes() {
        let xml1 = "<element test=\"hello\" />"
        let xml2 = "<element test=\"hello\"/>"
        let xml3 = "<element test=\"hello\"></element>"
        let xml4 = "<element><p test='hello'></p></element>"
        let xml5 = "<element><p test=\"hello\" /></element>"
        let parser = SwiftXMLParser()
        XCTAssertNoThrow(try parser.parse(xmlString: xml1))
        XCTAssertNoThrow(try parser.parse(xmlString: xml2))
        XCTAssertNoThrow(try parser.parse(xmlString: xml3))
        XCTAssertNoThrow(try parser.parse(xmlString: xml4))
        XCTAssertNoThrow(try parser.parse(xmlString: xml5))
    }
    
    func testElementStackDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            var operations: String = ""
            func didStartElement<S>(_ parser: SwiftXMLParser, elementName: S, namespaceURI: S?, attributes attributeDict: [S : S]) where S : StringProtocol {
                operations += "<\(elementName)>"
            }
            func didEndElement<S>(_ parser: SwiftXMLParser, elementName: S, namespaceURI: S?) where S : StringProtocol {
                operations += "</\(elementName)>"
            }
        }
        let xml = "<a><b><c/></b><d></d></a>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
        XCTAssertEqual(delegate.operations, "<a><b><c></c></b><d></d></a>")
    }
    
    func testAttributesDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            func didStartElement<S>(_ parser: SwiftXMLParser, elementName: S, namespaceURI: S?, attributes attributeDict: [S : S]) where S : StringProtocol {
                XCTAssertEqual(elementName, "a")
                XCTAssertEqual(attributeDict["b"], "test")
                XCTAssertEqual(attributeDict["c"], "test2")
            }
        }
        let xml = "<a b=\"test\" c='test2'/>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }
    
    func testCharacterDataDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            func foundCharacters<S>(_ parser: SwiftXMLParser, string: S) where S : StringProtocol {
                XCTAssertEqual(string, "testing testing 1,2,1,2")
            }
        }
        let xml = "<a>testing testing 1,2,1,2</a>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }
    
    func testCommentDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            func foundComment<S>(_ parser: SwiftXMLParser, comment: S) where S : StringProtocol {
                XCTAssertEqual(comment, "This is a comment")
            }
        }
        let xml = "<a><!--This is a comment--></a>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }

    func testEscapedCharacterDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            func foundCharacters<S>(_ parser: SwiftXMLParser, string: S) where S : StringProtocol {
                XCTAssertEqual(string, "testing <> testing &1,2,1,2")
            }
        }
        let xml = "<a>testing &lt;&gt; testing &amp;1,2,1,2</a>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }
    
    func testCharacterReferenceDelegate() {
        class Delegate: SwiftXMLParserDelegate {
            init() {}
            func foundCharacters<S>(_ parser: SwiftXMLParser, string: S) where S : StringProtocol {
                XCTAssertEqual(string, "testing A a é 😀")
            }
        }
        let xml = "<a>testing &#65; &#x61; &#233; &#x1f600;</a>"
        let parser = SwiftXMLParser()
        let delegate = Delegate()
        parser.delegate = delegate
        XCTAssertNoThrow(try parser.parse(xmlString: xml))
    }

    func testSpeed() throws {
        let xml = """
                <?xml version="1.0"?>
                <catalog>
                   <book id="bk101">
                      <author>Gambardella, Matthew</author>
                      <title>XML Developer's Guide</title>
                      <genre>Computer</genre>
                      <price>44.95</price>
                      <publish_date>2000-10-01</publish_date>
                      <description>An in-depth look at creating applications
                      with XML.</description>
                   </book>
                   <book id="bk102">
                      <author>Ralls, Kim</author>
                      <title>Midnight Rain</title>
                      <genre>Fantasy</genre>
                      <price>5.95</price>
                      <publish_date>2000-12-16</publish_date>
                      <description>A former architect battles corporate zombies,
                      an evil sorceress, and her own childhood to become queen
                      of the world.</description>
                   </book>
                   <book id="bk103">
                      <author>Corets, Eva</author>
                      <title>Maeve Ascendant</title>
                      <genre>Fantasy</genre>
                      <price>5.95</price>
                      <publish_date>2000-11-17</publish_date>
                      <description>After the collapse of a nanotechnology
                      society in England, the young survivors lay the
                      foundation for a new society.</description>
                   </book>
                   <book id="bk104">
                      <author>Corets, Eva</author>
                      <title>Oberon's Legacy</title>
                      <genre>Fantasy</genre>
                      <price>5.95</price>
                      <publish_date>2001-03-10</publish_date>
                      <description>In post-apocalypse England, the mysterious
                      agent known only as Oberon helps to create a new life
                      for the inhabitants of London. Sequel to Maeve
                      Ascendant.</description>
                   </book>
                   <book id="bk105">
                      <author>Corets, Eva</author>
                      <title>The Sundered Grail</title>
                      <genre>Fantasy</genre>
                      <price>5.95</price>
                      <publish_date>2001-09-10</publish_date>
                      <description>The two daughters of Maeve, half-sisters,
                      battle one another for control of England. Sequel to
                      Oberon's Legacy.</description>
                   </book>
                   <book id="bk106">
                      <author>Randall, Cynthia</author>
                      <title>Lover Birds</title>
                      <genre>Romance</genre>
                      <price>4.95</price>
                      <publish_date>2000-09-02</publish_date>
                      <description>When Carla meets Paul at an ornithology
                      conference, tempers fly as feathers get ruffled.</description>
                   </book>
                   <book id="bk107">
                      <author>Thurman, Paula</author>
                      <title>Splish Splash</title>
                      <genre>Romance</genre>
                      <price>4.95</price>
                      <publish_date>2000-11-02</publish_date>
                      <description>A deep sea diver finds true love twenty
                      thousand leagues beneath the sea.</description>
                   </book>
                   <book id="bk108">
                      <author>Knorr, Stefan</author>
                      <title>Creepy Crawlies</title>
                      <genre>Horror</genre>
                      <price>4.95</price>
                      <publish_date>2000-12-06</publish_date>
                      <description>An anthology of horror stories about roaches,
                      centipedes, scorpions  and other insects.</description>
                   </book>
                   <book id="bk109">
                      <author>Kress, Peter</author>
                      <title>Paradox Lost</title>
                      <genre>Science Fiction</genre>
                      <price>6.95</price>
                      <publish_date>2000-11-02</publish_date>
                      <description>After an inadvertant trip through a Heisenberg
                      Uncertainty Device, James Salway discovers the problems
                      of being quantum.</description>
                   </book>
                   <book id="bk110">
                      <author>O'Brien, Tim</author>
                      <title>Microsoft .NET: The Programming Bible</title>
                      <genre>Computer</genre>
                      <price>36.95</price>
                      <publish_date>2000-12-09</publish_date>
                      <description>Microsoft's .NET initiative is explored in
                      detail in this deep programmer's reference.</description>
                   </book>
                   <book id="bk111">
                      <author>O'Brien, Tim</author>
                      <title>MSXML3: A Comprehensive Guide</title>
                      <genre>Computer</genre>
                      <price>36.95</price>
                      <publish_date>2000-12-01</publish_date>
                      <description>The Microsoft MSXML3 parser is covered in
                      detail, with attention to XML DOM interfaces, XSLT processing,
                      SAX and more.</description>
                   </book>
                   <book id="bk112">
                      <author>Galos, Mike</author>
                      <title>Visual Studio 7: A Comprehensive Guide</title>
                      <genre>Computer</genre>
                      <price>49.95</price>
                      <publish_date>2001-04-16</publish_date>
                      <description>Microsoft Visual Studio 7 is explored in depth,
                      looking at how Visual Basic, Visual C++, C#, and ASP+ are
                      integrated into a comprehensive development
                      environment.</description>
                   </book>
                </catalog>
                """
        let xmlData = [UInt8](xml.utf8)
        let xmlData2 = Data(xml.utf8)
        var startTime = Date()
        class Delegate: NSObject, SwiftXMLParserDelegate, XMLParserDelegate {
            func didStartElement(_ parser: SwiftXMLParser, elementName: String, namespaceURI: String?, attributes attributeDict: [String : String]) {
            }
            
            func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            }
        }
        let delegate = Delegate()
        for _ in 0..<1000 {
            let parser = SwiftXMLParser()
            parser.delegate = delegate
            try parser.parse(xmlData: xmlData)
        }
        print(-startTime.timeIntervalSinceNow)
        startTime = Date()

        for _ in 0..<1000 {
            let parser2 = XMLParser(data: xmlData2)
            parser2.delegate = delegate
            parser2.parse()
        }
        print(-startTime.timeIntervalSinceNow)
    }
}
