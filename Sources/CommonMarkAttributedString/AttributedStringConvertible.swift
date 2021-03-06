import Foundation

#if canImport(AppKit)
import class AppKit.NSFont
import class AppKit.NSTextAttachment
import class AppKit.NSTextList

typealias Font = NSFont

#elseif canImport(UIKit)
import UIKit
typealias Font = UIFont
#endif

import CommonMark

public protocol AttributedStringConvertible {
    func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]
    func attributedString(attributes: [NSAttributedString.Key: Any], attachments: [String: NSTextAttachment]) throws -> NSAttributedString
}

// MARK: -

extension Node: AttributedStringConvertible {
    
    @objc public
    func attributes(with attributes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any] {
        return attributes
    }

    @objc public
    func attributedString(attributes: [NSAttributedString.Key: Any], attachments: [String: NSTextAttachment]) throws -> NSAttributedString {
        let attributes = self.attributes(with: attributes)

        switch self {
        case is SoftLineBreak:
            return NSAttributedString(string: " ", attributes: attributes)
        case is HardLineBreak, is ThematicBreak:
            return NSAttributedString(string: "\u{2028}", attributes: attributes)
        case let html as HTML:
//            return try html.attributedString(with: attributes)
            return NSAttributedString(string: html.literal ?? "", attributes: attributes)
        case let literal as Literal:
            return NSAttributedString(string: literal.literal ?? "", attributes: attributes)
        case let container as ContainerOfBlocks:
            guard !container.children.contains(where: { $0 is HTMLBlock }) else {
                let html = try Document(container.description).render(format: .html)
                return NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
            }

            return try container.children.map { try $0.attributedString(attributes: attributes, attachments: attachments) }.joined(separator: "\u{2029}")
        case let container as ContainerOfInlineElements:
            // jmj
//            guard !container.children.contains(where: { $0 is HTML }) else {
//                let html = try Document(container.description).render(format: .html)
//                return NSAttributedString(html: html, attributes: attributes) ?? NSAttributedString()
//            }
            return try container.children.map { try $0.attributedString(attributes: attributes, attachments: attachments) }.joined()
        case let list as List:
            return try list.children.enumerated().map { try $1.attributedString(in: list, at: $0, attributes: attributes, attachments: attachments) }.joined(separator: "\u{2029}")
        default:
            return NSAttributedString()
        }
    }
}

// MARK: Block Elements

extension BlockQuote {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)
        #if canImport(AppKit)
        attributes[.font] = font.addingSymbolicTraits(.italic)
        #else
        attributes[.font] = font.addingSymbolicTraits(.traitItalic)
        #endif


        return attributes
    }
}

extension CodeBlock {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)
        attributes[.font] = font.monospaced

        return attributes
    }
}

extension Heading {
    private var fontSizeMultiplier: CGFloat {
        switch level {
        case 1: return 2.00
        case 2: return 1.50
        case 3: return 1.17
        case 4: return 1.00
        case 5: return 0.83
        case 6: return 0.67
        default:
            return 1.00
        }
    }

    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)

        #if canImport(AppKit)
        attributes[.font] = Font(name: font.fontName, size: font.pointSize * fontSizeMultiplier)?.addingSymbolicTraits(.bold)
        #else
        attributes[.font] = Font(name: font.fontName, size: font.pointSize * fontSizeMultiplier)?.addingSymbolicTraits(.traitBold)
        #endif

        return attributes
    }
}

extension List {
    fileprivate var nestingLevel: Int {
        sequence(first: self) { $0.parent }.map { ($0 is List) ? 1 : 0}.reduce(0, +)
    }

    fileprivate var markerLevel: Int {
        sequence(first: self) { $0.parent }.map { ($0 as? List)?.kind == kind ? 1 : 0}.reduce(0, +)
    }
}

extension List.Item {
    private func ordinal(at position: Int) -> String {
        "\(position + 1)."
    }

    // TODO: Represent lists with NSTextList on macOS
    fileprivate func attributedString(in list: List, at position: Int, attributes: [NSAttributedString.Key: Any], attachments: [String: NSTextAttachment]) throws -> NSAttributedString {

        let delimiter: String
#if canImport(AppKit)
        if #available(OSX 10.13, *) {
            let format: NSTextList.MarkerFormat
            switch (list.kind, list.markerLevel) {
            case (.bullet, 1): format = .disc
            case (.bullet, 2): format = .circle
            case (.bullet, _): format = .square
            case (.ordered, 1): format = .decimal
            case (.ordered, 2): format = .lowercaseAlpha
            case (.ordered, _): format = .lowercaseRoman
            }

            delimiter = NSTextList(markerFormat: format, options: 0).marker(forItemNumber: position + 1)
        } else {
            delimiter = list.kind == .ordered ? "\(position + 1)." : "•"
        }
#else
        delimiter = list.kind == .ordered ? "\(position + 1)." : "•"
#endif
        
        let indentation = String(repeating: "\t", count: list.nestingLevel)

        let mutableAttributedString = NSMutableAttributedString(string: indentation + delimiter + " ", attributes: attributes)
        mutableAttributedString.append(try children.map { try $0.attributedString(attributes: attributes, attachments: attachments) }.joined(separator: "\u{2029}"))
        return mutableAttributedString
    }
}

// MARK: Inline Elements

// jmj
extension HTML {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        guard var html = self.literal else { return attributes }
        html.removeAll(where: { "</>".contains($0)})
        let words = html.split(separator: " ", maxSplits: 1)
        
        guard words.count == 2 else { return attributes }
        
        let key: NSAttributedString.Key
        
        switch words[0] {
        case "value":
            key = NSAttributedString.Key(rawValue: "ObjectValue")
        case "key":
            key = NSAttributedString.Key(rawValue: "ObjectValueKey")
        default:
            key = NSAttributedString.Key(String(words[0]))
        }
        attributes[key] = words[1]
        return attributes
    }
}

extension Code {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)
        attributes[.font] = font.monospaced

        return attributes
    }
}

extension Emphasis {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)
        #if canImport(AppKit)
        attributes[.font] = font.addingSymbolicTraits(.italic)
        #else
        attributes[.font] = font.addingSymbolicTraits(.traitItalic)
        #endif

        return attributes
    }
}

extension Image {
    public override func attributedString(attributes: [NSAttributedString.Key: Any], attachments: [String: NSTextAttachment]) throws -> NSAttributedString {
        guard let urlString = urlString else { return NSAttributedString() }
        guard let attachment = attachments[urlString] else { fatalError("missing attachment for \(urlString)") }
        return NSAttributedString(attachment: attachment)
    }
}

extension Link {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        if let urlString = urlString, let url = URL(string: urlString) {
            attributes[.link] = url
        }
#if canImport(AppKit)
        if let title = title {
            attributes[.toolTip] = title
        }
#endif
        return attributes
    }
}

extension Strong {
    public override func attributes(with attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var attributes = attributes

        let font = attributes[.font] as? Font ?? Font.systemFont(ofSize: Font.systemFontSize)
        #if canImport(AppKit)
        attributes[.font] = font.addingSymbolicTraits(.bold)
        #else
        attributes[.font] = font.addingSymbolicTraits(.traitBold)
        #endif

        return attributes
    }
}

extension Text {
    public override func attributedString(attributes: [NSAttributedString.Key: Any], attachments: [String: NSTextAttachment]) throws -> NSAttributedString {
        return NSAttributedString(string: literal ?? "", attributes: attributes)
    }
}
