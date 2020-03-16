
#if canImport(AppKit)

import class AppKit.NSFont
import class AppKit.NSFontDescriptor


extension NSFont {
    func addingSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(traits)
        return NSFont(descriptor: fontDescriptor.withSymbolicTraits(symbolicTraits), size: pointSize)
    }
    
    var monospaced: NSFont? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(.monoSpace)
        
        guard let fontDescriptor = NSFont.userFixedPitchFont(ofSize: pointSize)?.fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        
        return NSFont(descriptor: fontDescriptor, size: pointSize)
    }
}

#elseif canImport(UIKit)
import UIKit

extension Font {
    func addingSymbolicTraits(_ traits: FontDescriptor.SymbolicTraits) -> Font? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(traits)
        guard let fd = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return Font(descriptor: fd, size: pointSize)
    }

    var monospaced: Font? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(.traitMonoSpace)
        guard let fd = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return Font(descriptor: fd, size: pointSize)
    }
}

#endif

