//
//  ProfanityFilter.swift
//  MateZ
//
//  Created by Aryan Garg on 15/06/23.
//
import Foundation
import SwiftUI

public class ProfanityFilter {
    
    private let blackList: [String]
    
    private let whiteList: [String]?
    
    public init(blackList: [String] = BlackList.defaultList, whiteList: [String]? = nil) {
        self.blackList = blackList
        self.whiteList = whiteList
    }
    
    public func containsProfanity(text: String) -> ProfanityResult {
        do {
            let rgx = try regex()
            let matches = rgx.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return ProfanityResult(profanities: matches.map {
                String(text[Range($0.range, in: text)!])
            })
        } catch {
            return ProfanityResult(profanities: [])
        }
    }
    
    public func maskProfanity(text: String) -> String {
        do {
            let rgx = try regex()
            let matches = rgx.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            
            var new = text
            for match in matches {
                let range = Range(match.range, in: new)!
                new.replaceSubrange(range, with: Array(repeating: "*", count: match.range.length))
            }
            
            return new
        } catch {
            return ""
        }
    }
    
    private func regex() throws -> NSRegularExpression {
        
        let escapedPattern = { (text: String) -> String in
            "\\b(\(NSRegularExpression.escapedPattern(for: text)))\\b"
        }
        
        let profanities = getProfanityList()
            .map(escapedPattern)
            .joined(separator: "|")
        
       return try NSRegularExpression(
            pattern: "[^!@#$%^&*]*\(profanities)[^!@#$%^&*]*",
            options: [.caseInsensitive])
    }
    
    private func getProfanityList() -> [String] {
        if let whiteList = self.whiteList {
            var blackList = Array(self.blackList)
            blackList.removeAll { whiteList.contains($0) }
            return blackList
        }
        
        return self.blackList
    }
}

public struct ProfanityResult {
    
    public var containsProfanity: Bool {
        return profanities.count > 0
    }
    
    public let profanities: [String]
}

