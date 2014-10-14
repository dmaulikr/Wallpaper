//
//  Wallpaper.swift
//  Wallpaper
//
//  Created by Eric Miller on 8/21/14.
//  Copyright (c) 2014 Xero. All rights reserved.
//

import UIKit
import Foundation

public enum WPTextParagraphLength : String {
    case VeryShort = "veryshort"
    case Short = "short"
    case Medium = "medium"
    case Long = "long"
    case VeryLong = "verylong"
}

private struct WallpaperImageURLString {
    static let PlaceKitten = "http://placekitten.com/%@/%@"
    static let PlaceKittenGreyscale = "http://placekitten.com/g/%@/%@"
    static let Bacon = "http://baconmockup.com/%@/%@/"
    static let PlaceHolder = "http://placehold.it/%@x%@/"
    static let Random = "http://lorempixel.com/%@/%@/"
    static let RandomGreyscale = "http://lorempixel.com/g/%@/%@/"
    static let Downey = "http://rdjpg.com/%@/%@/"
}

private let kWPPlaceRandomTextURLString = "http://loripsum.net/api/"
private let ColorAlphaLimit: Double = 0.1

public func == (lhs: WPTextOptions, rhs: WPTextOptions) -> Bool {
    return lhs.value == rhs.value
}

public func == (lhs: WPHTMLOptions, rhs: WPHTMLOptions) -> Bool {
    return lhs.value == rhs.value
}

public struct WPTextOptions : RawOptionSetType, BooleanType {
    public typealias RawValue = UInt
    private var value: UInt = 0
    public init(nilLiteral: ()) {}
    public init(rawValue value: UInt) { self.value = value }
    public var boolValue: Bool { return self.value != 0 }
    public func toRaw() -> UInt { return self.value }
    public static var allZeros: WPTextOptions { return self(rawValue: 0) }
    public static func fromRaw(raw: UInt) -> WPTextOptions? { return self(rawValue: raw) }
    public static func fromMask(raw: UInt) -> WPTextOptions { return self(rawValue: raw) }
    public static func convertFromNilLiteral() -> WPTextOptions { return self(rawValue: 0) }
    public var rawValue: RawValue {
        get {
            return self.value
        }
    }

    static var None: WPTextOptions { return self(rawValue: 0) }
    static var AllCaps: WPTextOptions { return self(rawValue: 1 << 0) }
    static var Prude: WPTextOptions { return self(rawValue: 1 << 1) }

    private struct Feature {
        static let AllCaps = "allcaps"
        static let PrudeText = "prude"
    }

    public func toMaskString() -> String {
        var urlString = ""
        if (self & .AllCaps) {
            urlString = urlString.stringByAppendingPathComponent(Feature.AllCaps)
        }

        if (self & .Prude) {
            urlString = urlString.stringByAppendingPathComponent(Feature.PrudeText)
        }

        return urlString
    }
}

public struct WPHTMLOptions : RawOptionSetType, BooleanType {
    public typealias RawValue = UInt
    private var value: UInt = 0
    public init(nilLiteral: ()) {}
    public init(rawValue value: UInt) { self.value = value }
    public var boolValue: Bool { return self.value != 0 }
    public func toRaw() -> UInt { return self.value }
    public static var allZeros: WPHTMLOptions { return self(rawValue: 0) }
    public static func fromRaw(raw: UInt) -> WPHTMLOptions? { return self(rawValue: raw) }
    public static func fromMask(raw: UInt) -> WPHTMLOptions { return self(rawValue: raw) }
    public static func convertFromNilLiteral() -> WPHTMLOptions { return self(rawValue: 0) }
    public var rawValue: RawValue {
        get {
            return self.value
        }
    }

    static var None:             WPHTMLOptions { return self(rawValue: 0) }
    static var EmphasisTags:     WPHTMLOptions { return self(rawValue: 1 << 0) }
    static var AnchorTags:       WPHTMLOptions { return self(rawValue: 1 << 1) }
    static var UnorderedList:    WPHTMLOptions { return self(rawValue: 1 << 2) }
    static var OrderedList:      WPHTMLOptions { return self(rawValue: 1 << 3) }
    static var DescriptionList:  WPHTMLOptions { return self(rawValue: 1 << 4) }
    static var Blockquotes:      WPHTMLOptions { return self(rawValue: 1 << 5) }
    static var CodeSamples:      WPHTMLOptions { return self(rawValue: 1 << 6) }
    static var Headers:          WPHTMLOptions { return self(rawValue: 1 << 7) }
    static var AllCaps:          WPHTMLOptions { return self(rawValue: 1 << 8) }
    static var Prude:            WPHTMLOptions { return self(rawValue: 1 << 9) }

    private struct Feature {
        static let Links = "link"
        static let Emphasis = "decorate"
        static let UnorderedList = "u1"
        static let OrderedList = "o1"
        static let DescriptionList = "d1"
        static let Blockquotes = "bq"
        static let CodeSamples = "code"
        static let Headers = "headers"
        static let AllCaps = "allcaps"
        static let PrudeText = "prude"
    }

    public func toURLPathString() -> String {
        var optionsString: String = ""

        if (self & .AnchorTags) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Links)
        }
        if (self & .EmphasisTags) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Emphasis)
        }
        if (self & .UnorderedList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.UnorderedList)
        }
        if (self & .OrderedList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.OrderedList)
        }
        if (self & .DescriptionList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.DescriptionList)
        }
        if (self & .Blockquotes) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Blockquotes)
        }
        if (self & .CodeSamples) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.CodeSamples)
        }
        if (self & .Headers) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Headers)
        }
        if (self & .AllCaps) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.AllCaps)
        }
        if (self & .Prude) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.PrudeText)
        }

        return optionsString
    }
}

public class Wallpaper: NSObject {

    private class func requestImage(path: String, size: CGSize, completion: (image: UIImage?) -> ()) {
        let screenScale: CGFloat = UIScreen.mainScreen().scale

        let urlString = NSString(format: path, "\(Int(size.width * screenScale))", "\(Int(size.height * screenScale))")
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data, scale: screenScale)
                completion(image: image);
            } else {
                println("\(__FUNCTION__) Wallpaper Error: \(error)")
                completion(image: nil)
            }
        }
    }
}

//MARK: - Images
public extension Wallpaper {

    public class func placeKittenImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceKitten, size: size, completion: completion)
    }

    public class func placeKittenGreyscaleImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceKittenGreyscale, size: size, completion: completion)
    }

    public class func placeBaconImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Bacon, size: size, completion: completion)
    }

    public class func placeHolderImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceHolder, size: size, completion: completion)
    }

    public class func placeRandomImage(size: CGSize, category: String, completion: (image: UIImage?) -> ()) {
        let path = WallpaperImageURLString.Random.stringByAppendingPathComponent(category)
        requestImage(path, size: size, completion: completion)
    }

    public class func placeRandomGreyscaleImage(size: CGSize, category: String, completion: (image: UIImage?) -> ()) {
        let path = WallpaperImageURLString.RandomGreyscale.stringByAppendingPathComponent(category)
        requestImage(path, size: size, completion: completion)
    }

    public class func placeRandomImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Random, size: size, completion: completion)
    }

    public class func placeRandomGreyscaleImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.RandomGreyscale, size: size, completion: completion)
    }

    public class func placeDowneyImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Downey, size: size, completion: completion)
    }
}


//MARK: - Text
public extension Wallpaper {

    public class func placeText(numberOfParagraphs: Int, paragraphLength: WPTextParagraphLength, textOptions: WPTextOptions, completion: (placeText: String?) -> ()) {
        assert(numberOfParagraphs > 0, "Number of paragraphs is invalid")

        var urlString = kWPPlaceRandomTextURLString.stringByAppendingString(textOptions.toMaskString())
        urlString = urlString.stringByAppendingPathComponent("plaintext")
        urlString = urlString.stringByAppendingPathComponent(paragraphLength.rawValue)

        let paragraphArgs = "\(numberOfParagraphs)"
        urlString = urlString.stringByAppendingPathComponent(paragraphArgs)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
         NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let returnString = NSString(data: data, encoding: NSUTF8StringEncoding)
                completion(placeText: returnString)
            } else {
                println("\(__FUNCTION__) Wallpaper Error: \(error)")
                completion(placeText: nil)
            }
        }
    }

    public class func placeHipsterIpsum(numberOfParagraphs: Int, shotOfLatin: Bool, completion: (hipsterIpsum: String?) -> ()) {
        var hipsterPath: String = "http://hipsterjesus.com/api?paras=\(numberOfParagraphs)&html=false"
        if shotOfLatin {
            hipsterPath += "&type=hipster-latin"
        } else {
            hipsterPath += "&type=hipster-centric"
        }

        let url = NSURL(string: hipsterPath)
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as NSDictionary
                let returnString = dict["text"] as String
                completion(hipsterIpsum: returnString)
            } else {
                println("\(__FUNCTION__) Wallpaper Error: \(error)")
                completion(hipsterIpsum: nil)
            }
        }
    }

    public class func placeHTML(numberOfParagraphs: Int, paragraphLength: WPTextParagraphLength, options: WPHTMLOptions, completion: (placeText: String?) -> ()) -> () {
        let htmlURL = placeURLForHTML(paragraphLength, htmlOptions: options)
        let request = NSURLRequest(URL: htmlURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let returnString = NSString(data: data, encoding: NSUTF8StringEncoding)
                completion(placeText: returnString)
            } else {
                println("\(__FUNCTION__) Wallpaper Error: \(error)")
                completion(placeText: nil)
            }
        }
    }

    public class func placeURLForHTML(paragraphLength: WPTextParagraphLength, htmlOptions: WPHTMLOptions) -> NSURL {
        let htmlURLString = kWPPlaceRandomTextURLString
        let optionsString = htmlOptions.toURLPathString()

        let lengthURLString = htmlURLString + "\(paragraphLength.rawValue)"
        let fullURLString = lengthURLString + "/\(optionsString)"

        return NSURL(string: fullURLString)!
    }
}

//MARK: - Colors
public extension Wallpaper {

    public class func placeRandomColorWithHue(hue: CGFloat) -> UIColor {
        assert(hue <= 1 && hue >= 0, "Hue value must be between 0 and 1")

        let upperLimit = 100
        let lowerLimit = 10

        let percentRange = NSMakeRange(lowerLimit, upperLimit - lowerLimit)

        let s = randomPercentage(percentRange)
        let b = randomPercentage(percentRange)

        return UIColor(hue: hue, saturation: s, brightness: b, alpha: 1.0)
    }

    public class func placeRandomColor() -> UIColor {
        return placeRandomColorWithAlpha(1.0)
    }

    public class func placeRandomColorWithAlpha(alpha: CGFloat) -> UIColor {
        let r = randomPercentage()
        let g = randomPercentage()
        let b = randomPercentage()

        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    public class func placeRandomColorWithRandomAlpha() -> UIColor {
        let alpha = max(randomPercentage(), CGFloat(ColorAlphaLimit))
        return placeRandomColorWithAlpha(alpha)
    }

    public class func placeRandomGreyscaleColor() -> UIColor {
        return placeRandomGreyscaleColor(1.0)
    }

    public class func placeRandomGreyscaleColor(alpha: CGFloat) -> UIColor {
        let greyness = min(max(randomPercentage(), CGFloat(ColorAlphaLimit)), CGFloat((1.0 - ColorAlphaLimit)))
        return UIColor(white: greyness, alpha: alpha)
    }

    public class func placeRandomGreyscaleColorWithRandomAlpha() -> UIColor {
        let alpha = max(randomPercentage(), CGFloat(ColorAlphaLimit))
        return placeRandomGreyscaleColor(alpha)
    }

    public class func placeRandomColorWithHueOfColor(color: UIColor) -> UIColor {
        var hue: CGFloat = 0.0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return placeRandomColorWithHue(hue)
    }
}

//MARK: - Private Random Number Helpers
private extension Wallpaper {

    private class func randomPhoneNumber() -> String {
        return "(\(arc4random_uniform(000))) \(arc4random_uniform(999))-\(arc4random_uniform(9999))"
    }

    private class func randomInteger(lessThan: UInt32) -> Int {
        return Int(arc4random_uniform(lessThan))
    }

    private class func randomFloat(lessThan: UInt32) -> CGFloat {
        return (CGFloat(arc4random_uniform(lessThan)) + randomPercentage())
    }

    private class func randomFloat(range: NSRange) -> CGFloat {
        return (CGFloat(range.location + arc4random_uniform(UInt32(range.length))) + randomPercentage())
    }

    private class func randomPercentage() -> CGFloat {
        return (CGFloat(arc4random_uniform(100)) / 100.0)
    }

    private class func randomPercentage(range: NSRange) -> CGFloat {
        return (CGFloat(range.location + arc4random_uniform(UInt32(range.length))) / 100.0)
    }
}
