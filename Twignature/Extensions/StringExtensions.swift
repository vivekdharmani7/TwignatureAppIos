//
//  StringExtensions.swift
//  Twignature
//
//  Created by Ivan Hahanov on 5/12/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

typealias Tag = String

extension String {
    
    func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    var attributed: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }
    
    var range: NSRange {
        return NSRange(location: 0, length: self.characters.count)
    }
    
    func index(of string: String, options: CompareOptions = .literal) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: string, options: []) else { return nil }
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
        return matches.first?.range.location
    }
    
    func findHashtag(at position: Int) -> String? {
        let matches = RegexValidator(pattern: Regex.hashtag).matches(for: self)
        for match in matches {
            if position > match.range.location && position <= match.range.location + match.range.length {
                return (self as NSString).substring(with: match.range)
            }
        }
        return nil
    }
    
    func findMatches(regex: String) -> [NSTextCheckingResult] {
        return RegexValidator(pattern: regex).matches(for: self)
    }
    
    func findUser(at position: Int) -> (NSRange, String)? {
        let matches = RegexValidator(pattern: Regex.user).matches(for: self)
        for match in matches {
            if position >= match.range.location && position < match.range.location + match.range.length {
                return (match.range, (self as NSString).substring(with: match.range))
            }
        }
        return nil
    }
    
    mutating func replaceString(in range: NSRange, with string: String) {
        self = (self as NSString).replacingCharacters(in: range, with: "")
        self.insert(contentsOf: string.characters,
                    at: self.index(self.startIndex, offsetBy: range.location))
    }
    
    func range(for string: String) -> NSRange? {
        guard let start = index(of: string) else { return nil }
        return NSRange(location: start, length: string.characters.count)
    }
    
    func matches(regex: String) -> Bool {
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    func findUsers() -> [NSTextCheckingResult] {
        return RegexValidator(pattern: Regex.user).matches(for: self)
    }
    
    func findHashtags() -> [NSTextCheckingResult] {
        return RegexValidator(pattern: Regex.hashtag).matches(for: self)
    }
    
    fileprivate func taggedRange(tag: Tag) -> NSRange? {
        guard let start = index(of: "<\(tag)>"),
            let end = index(of: "</\(tag)>") else { return nil }
        return NSRange(location: start, length: end - start)
    }
    
    func localized(file: String) -> String {
        return NSLocalizedString(self, tableName: file, bundle: Bundle.main, comment: "")
    }
    
    func sizeForText(forContainerWithWidth containerWidth: CGFloat, font: UIFont) -> CGSize {
        let size = CGSize(width: containerWidth, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let attributes: [String: Any] = [NSFontAttributeName: font]
        return (self as NSString).boundingRect(with: size, options: options, attributes: attributes, context: nil).size
    }
}

extension NSMutableAttributedString {
    
    func image(_ image: UIImage, for tag: String) -> NSMutableAttributedString {
        let new = NSMutableAttributedString(attributedString: self)
        guard let tagRange = string.range(for: "<\(tag)>") else { return self }
        new.replaceCharacters(in: tagRange, with: image.string)
        return new
    }
    
    func image(_ image: UIImage) -> NSMutableAttributedString {
        let new = NSMutableAttributedString(attributedString: self)
        new.append(image.string)
        return new
    }
    
    func image(_ image: UIImage, at pos: Int) -> NSMutableAttributedString {
        let left = NSMutableAttributedString(attributedString: attributedSubstring(from: NSRange(location: 0, length: pos)))
        let right = attributedSubstring(from: NSRange(location: pos, length: string.count - pos))
        let full = left.image(image)
        full.append(right)
        return full
    }
    
    func alignment(_ alignment: NSTextAlignment) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        let new = NSMutableAttributedString(attributedString: self)
        new.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: string.range)
        return new
    }
    
    // MARK: - Tags
    
    func baselineOffset(_ offset: Double, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSBaselineOffsetAttributeName, value: offset, tag: tag)
    }
    
    func paragraphStyle(_ style: NSParagraphStyle, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSParagraphStyleAttributeName, value: style, tag: tag)
    }
        
    func font(_ font: UIFont, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSFontAttributeName, value: font, tag: tag)
    }
    
    func color(_ color: UIColor, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSForegroundColorAttributeName, value: color, tag: tag)
    }
    
    func kern(_ kern: CGFloat, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSKernAttributeName, value: kern, tag: tag)
    }
    
    func link(_ link: String = "a", for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSLinkAttributeName, value: link, tag: tag)
    }
    
    func underline(_ style: NSUnderlineStyle = .styleSingle, for tag: Tag? = nil) -> NSMutableAttributedString {
        return applyAttribute(name: NSUnderlineStyleAttributeName, value: style.rawValue, tag: tag)
    }
    
    // MARK: - Mentions
    
    func font(_ font: UIFont, mention: String) -> NSMutableAttributedString {
        return applyAttribute(name: NSFontAttributeName, value: font, mention: mention)
    }
    
    func color(_ color: UIColor, mention: String) -> NSMutableAttributedString {
        return applyAttribute(name: NSForegroundColorAttributeName, value: color, mention: mention)
    }
    
    func kern(_ kern: CGFloat, mention: String) -> NSMutableAttributedString {
        return applyAttribute(name: NSKernAttributeName, value: kern, mention: mention)
    }
    
    func link(_ link: String = "a", mention: String) -> NSMutableAttributedString {
        return applyAttribute(name: NSLinkAttributeName, value: link, mention: mention)
    }
    
    // MARK: - Range
    
    func underline(_ style: NSUnderlineStyle = .styleSingle, ranges: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            result.applyAttributeInPlace(name: NSUnderlineStyleAttributeName, value: style.rawValue, range: range)
        }
        return result
    }
    
    func font(_ font: UIFont, ranges: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            result.applyAttributeInPlace(name: NSFontAttributeName, value: font, range: range)
        }
        return result
    }
    
    func color(_ color: UIColor, ranges: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            result.applyAttributeInPlace(name: NSForegroundColorAttributeName, value: color, range: range)
        }
        return result
    }
    
    func kern(_ kern: CGFloat, ranges: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            result.applyAttributeInPlace(name: NSKernAttributeName, value: kern, range: range)
        }
        return result
    }
    
    func link(_ link: String = "a", ranges: [NSRange]) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            result.applyAttributeInPlace(name: NSLinkAttributeName, value: link, range: range)
        }
        return result
    }
    
    private func applyAttribute(name: String, value: Any, mention: String) -> NSMutableAttributedString {
        guard let range = string.range(for: mention) else {
            return applyAttribute(name: name, value: value, range: string.range)
        }
        return applyAttribute(name: name, value: value, range: range)
    }
    
    private func applyAttribute(name: String, value: Any, tag: Tag? = nil) -> NSMutableAttributedString {
        guard let tag = tag, let range = string.taggedRange(tag: tag) else {
            return applyAttribute(name: name, value: value, range: string.range)
        }
        return applyAttribute(name: name, value: value, range: range)
    }
    
    private func applyAttribute(name: String, value: Any, range: NSRange) -> NSMutableAttributedString {
        let new = NSMutableAttributedString(attributedString: self)
        new.addAttribute(name, value: value, range: range)
        return new
    }
    
    var clear: NSAttributedString {
        let new = NSMutableAttributedString(attributedString: self)
        new.string.findMatches(regex: "<[a-z]>").forEach { new.replaceCharacters(in: $0.range, with: "") }
        new.string.findMatches(regex: "</[a-z]>").forEach { new.replaceCharacters(in: $0.range, with: "") }
        return new
    }
}

extension NSMutableAttributedString {
    fileprivate func applyAttributeInPlace(name: String, value: Any, range: NSRange) {
        self.addAttribute(name, value: value, range: range)
    }
}
