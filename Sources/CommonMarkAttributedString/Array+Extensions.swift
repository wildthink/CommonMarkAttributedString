// import class AppKit.NSAttributedString
// import class AppKit.NSMutableAttributedString
import Foundation

extension Array where Element == NSAttributedString {
    func joined(separator: String? = nil) -> NSAttributedString {
        guard let first = first else { return NSAttributedString() }
        guard count > 1 else { return first }
        
        return suffix(from: startIndex.advanced(by: 1)).reduce(NSMutableAttributedString(attributedString: first)) { (mutableAttributedString, attributedString) in
            if let separator = separator {
                mutableAttributedString.append(NSAttributedString(string: separator))
            }
            
            mutableAttributedString.append(attributedString)
            
            return mutableAttributedString
        }
    }
}
