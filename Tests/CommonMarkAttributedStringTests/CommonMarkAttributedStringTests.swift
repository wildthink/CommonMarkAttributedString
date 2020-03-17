import XCTest
import CommonMarkAttributedString

final class CommonMarkAttributedStringTests: XCTestCase {
    func testReadmeExample() throws {
        let commonmark = "A *bold* way to add __emphasis__ to your `code`"

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24.0),
            .foregroundColor: NSColor.systemBlue,
        ]

        let attributedString = try NSAttributedString(commonmark: commonmark, attributes: attributes)

        XCTAssertEqual(attributedString.string, "A bold way to add emphasis to your code")
    }

    func testHTMLExample() throws {
        let commonmark = "A *bold* <key skeleton/> way to add __emphasis__ to your `code`"

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 24.0),
            .foregroundColor: NSColor.systemBlue,
        ]

        let attributedString = try NSAttributedString(commonmark: commonmark, attributes: attributes)

        XCTAssertEqual(attributedString.string, "A bold <key skeleton/> way to add emphasis to your code")
    }

    func testUHDR() throws {
        let commonmark = #"""
        # [Universal Declaration of Human Rights][uhdr]

        ## Article 1.

        All human beings are born free and equal in dignity and rights.
        They are endowed with reason and conscience
        and should act towards one another in a spirit of brotherhood.

        [uhdr]: https://www.un.org/en/universal-declaration-human-rights/ "View full version"
        """#

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
            .foregroundColor: NSColor.textColor,
            .backgroundColor: NSColor.textBackgroundColor,
        ]

        let attributedString = try NSAttributedString(commonmark: commonmark, attributes: attributes)

        XCTAssert(attributedString.string.starts(with: "Universal Declaration of Human Rights"))
    }
}
