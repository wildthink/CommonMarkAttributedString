import Foundation

#if canImport(AppKit)
import class AppKit.NSTextAttachment
#elseif canImport(UIKit)
import UIKit
#endif

import CommonMark

extension NSAttributedString {

    /**
     Create an attributed string from CommonMark text.
     - Parameters:
     - commonmark: A string containing text in CommonMark format.
     - attributes: A dictionary of base attributes to apply, if any.
     - attachments: A dictionary of text attachments keyed by URL strings
                    corresponding to images in the CommonMark text.
     */
    public convenience init(commonmark: String, attributes: [NSAttributedString.Key: Any]? = nil, attachments: [String: NSTextAttachment]? = nil) throws {
        let document = try CommonMark.Document(commonmark)
        try self.init(attributedString: document.attributedString(attributes: attributes ?? [:], attachments: attachments ?? [:]))
    }
    
    convenience init?(html: String, attributes: [NSAttributedString.Key: Any]) {

        // FIXME: jmj
        self.init(string: html)

        //  guard let data = html.data(using: .utf8) else { return nil }
         /*
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        var documentAttributes: NSDictionary? = [:]
        guard let mutableAttributedString = NSMutableAttributedString(html: data, options: options, documentAttributes: &documentAttributes) else {
            return nil
        }
        
        mutableAttributedString.addAttributes(attributes, range: NSMakeRange(0, mutableAttributedString.length))
        
        self.init(attributedString: mutableAttributedString)
 */
    }
}

