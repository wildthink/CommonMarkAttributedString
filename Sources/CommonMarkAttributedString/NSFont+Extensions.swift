#if canImport(AppKit)
import class AppKit.NSFont
import class AppKit.NSFontDescriptor
typealias Font = NSFont
#elseif canImport(UIKit)
import UIKit
typealias FontDescriptor = UIFontDescriptor
#endif

extension Font {
    func addingSymbolicTraits(_ traits: FontDescriptor.SymbolicTraits) -> Font? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(traits)
        guard let fd = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return Font(descriptor: fd, size: pointSize)
    }

#if canImport(AppKit)

    var monospaced: Font? {
        var symbolicTraits = fontDescriptor.SymbolicTraits
        symbolicTraits.insert(.monoSpace)
        
        guard let fontDescriptor = Font.userFixedPitchFont(ofSize: pointSize)?.fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        
        return Font(descriptor: fontDescriptor, size: pointSize)
    }
#else
    var monospaced: Font? {
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.insert(.traitMonoSpace)
        guard let fd = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return Font(descriptor: fd, size: pointSize)
    }
#endif
}

