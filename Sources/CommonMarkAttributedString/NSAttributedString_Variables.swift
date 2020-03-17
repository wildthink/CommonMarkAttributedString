//
//  NSAttributedString_Variables.swift
//  CodeBase
//
//  Created by Jason Jobe on 1/28/18.
//

import Foundation

extension NSAttributedString.Key {
    public static var value = NSAttributedString.Key("ObjectValue")
    public static var valueKey = NSAttributedString.Key("ObjectValueKey")
}

extension NSMutableAttributedString {

    public func update (values: [String: CustomStringConvertible], in range: NSRange? = nil) {
        let range = range ?? fullRange
        self.enumerateAttribute(.valueKey, in: range, options: [])
        { (key, range, stop) -> Void in
            guard let key = key as? String, let newValue = values[key]
                else { return }
            // let oldValue = self.attribute(.value, at: range.location, effectiveRange: nil)
            self.addAttribute(.value, value: newValue, range: range)
            self.replaceCharacters(in: range, with: newValue.description)
        }
    }
}

extension NSAttributedString {

    public var fullRange: NSRange { return NSRange(location: 0, length:self.length) }

    public func hasVariables() -> Bool {

        var flag = false
        self.enumerateAttribute(.valueKey, in: fullRange, options: [])
        { (key, range, stop) -> Void in
            guard key != nil else { return }
            flag = true
            stop.pointee = ObjCBool(true)
        }
        return flag
    }

    public func variables(in range: NSRange? = nil) -> [String: CustomStringConvertible]
    {
        var values = [String: CustomStringConvertible]()
        let range = range ?? fullRange
        self.enumerateAttribute(.valueKey, in: range, options: [])
        { (key, range, stop) -> Void in
            guard let key = key as? String else { return }
            let text = self.attributedSubstring(from: range).string
            values[key] = text
        }
        return values
    }

    public func nextVariable (from pos: Int, reverse: Bool = false) -> (String, CustomStringConvertible)?
    {
        let range = reverse
                    ? NSRange(location: 0, length: pos)
                    : NSRange(location: pos, length: self.length - pos)
        var r_key: String?
        var r_value: CustomStringConvertible?

        self.enumerateAttribute(.valueKey, in: range, options: (reverse ? [.reverse] : []))
        { (key, range, stop) -> Void in
            guard let key = key as? String else { return }
            r_value = self.attribute(.value, at: range.location, effectiveRange: nil) as? CustomStringConvertible ?? self.attributedSubstring(from: range).string
            r_key = key
            stop.pointee = ObjCBool(true)
        }
        guard let key = r_key, let value = r_value
            else { return nil }
        return (key, value)
    }
}

/////////////////////////////////////

extension CustomStringConvertible {
    public func template (variable: String) -> NSAttributedString {
        return NSAttributedString (string: self.description,
                                   attributes: [.value: self, .valueKey: variable])
    }
}


