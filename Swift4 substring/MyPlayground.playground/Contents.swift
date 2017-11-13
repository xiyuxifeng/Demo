//: Playground - noun: a place where people can play

import UIKit

var s = "abcdefg"
s.count //7
let index = s.index(s.startIndex, offsetBy: 4)

let s2 = s.prefix(2) // "ab"
let s3 = s.suffix(2) // "fg"

let s4 = s.prefix(upTo: index) // "abcd"

let startIndex = s.index(s.startIndex, offsetBy: 1)
let endIndex = s.index(s.startIndex, offsetBy: 5)
let s5 = s[startIndex...endIndex] // "bcdef"
let s6 = s[startIndex..<endIndex] // "bcde"

extension String {
    //subscript(r: CountableClosedRange<Int>) -> String
    subscript(bound: Range<Int>) -> String {
        var lower = bound.lowerBound
        var upper = bound.upperBound
        
        if lower > upper {
            (lower, upper) = (upper, lower)
        }
        
        if upper > self.count {
            upper = self.count
        }
        
        let start = self.index(startIndex, offsetBy: lower)
        let end = self.index(startIndex, offsetBy: upper)
        let sub = self[start..<end]
        return String(sub)
    }
    
    subscript(range: CountableRange<Int>) -> String {
        let bound = Range(range.lowerBound..<range.upperBound)
        return self[bound]
    }
    
    subscript(range: CountableClosedRange<Int>) -> String {
        let bound = Range(range.lowerBound...range.upperBound)
        return self[bound]
    }
    
    subscript(range: CountablePartialRangeFrom<Int>) -> String {
        let start = self.index(startIndex, offsetBy: range.lowerBound)
        let sub = self.suffix(from: start)
        return String(sub)
    }
    
    subscript(range: PartialRangeThrough<Int>) -> String {
        let end = self.index(startIndex, offsetBy: range.upperBound)
        let sub = self.prefix(through: end)
        return String(sub)
    }
    
    subscript(range: PartialRangeUpTo<Int>) -> String {
        let end = self.index(startIndex, offsetBy: range.upperBound)
        let sub = self.prefix(upTo: end)
        return String(sub)
    }
}

// Range<Int>
let r1 = Range(1...2)       // Range(1..<3)
let s7 = s[r1]              // "bc"
let s8 = s[Range(1..<2)]    // "b"
let s9 = s[Range(1...1)]    // "b"
let s10 = s[Range(1..<1)]   // ""

// range: CountableRange<Int>
let s11 = s[1..<2]          // "b"
let s12 = s[1...2]          // "bc"
let s13 = s[1..<8]          // "bcdefg"

let s14 = s[2...]           // "cdefg"
let s15 = s[...4]           // "abcde"

let s16 = s[..<4]           // "abcd"





