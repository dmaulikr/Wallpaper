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

private enum WallpaperImageURLString : String {
    case PlaceKitten = "http://placekitten.com/%@/%@"
    case PlaceKittenGreyscale = "http://placekitten.com/g/%@/%@"
    case Bacon = "http://baconmockup.com/%@/%@/"
    case PlaceHolder = "http://placehold.it/%@x%@/"
    case Random = "http://lorempixel.com/%@/%@/"
    case RandomGreyscale = "http://lorempixel.com/g/%@/%@/"
    case Downey = "http://rdjpg.com/%@/%@/"
}

private let kWPPlaceRandomTextURLString = "http://loripsum.net/api/"
private let ColorAlphaLimit: Double = 0.1

public struct WPTextOptions : RawOptionSetType, BooleanType {
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    public var boolValue: Bool { return self.value != 0 }
    public func toRaw() -> UInt { return self.value }
    public static var allZeros: WPTextOptions { return self(0) }
    public static func fromRaw(raw: UInt) -> WPTextOptions? { return self(raw) }
    public static func fromMask(raw: UInt) -> WPTextOptions { return self(raw) }
    public static func convertFromNilLiteral() -> WPTextOptions { return self(0) }

    static var None: WPTextOptions { return self(0) }
    static var AllCaps: WPTextOptions { return self(1 << 0) }
    static var Prude: WPTextOptions { return self(1 << 1) }

    private enum Feature: String {
        case AllCaps = "allcaps"
        case PrudeText = "prude"
    }

    public func toMaskString() -> String {
        var urlString = ""
        if (self & .AllCaps) {
            urlString = urlString.stringByAppendingPathComponent(Feature.AllCaps.toRaw())
        }

        if (self & .Prude) {
            urlString = urlString.stringByAppendingPathComponent(Feature.PrudeText.toRaw())
        }

        return urlString
    }
}

public struct WPHTMLOptions : RawOptionSetType, BooleanType {
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    public var boolValue: Bool { return self.value != 0 }
    public func toRaw() -> UInt { return self.value }
    public static var allZeros: WPHTMLOptions { return self(0) }
    public static func fromRaw(raw: UInt) -> WPHTMLOptions? { return self(raw) }
    public static func fromMask(raw: UInt) -> WPHTMLOptions { return self(raw) }
    public static func convertFromNilLiteral() -> WPHTMLOptions { return self(0) }

    static var None:             WPHTMLOptions { return self(0) }
    static var EmphasisTags:     WPHTMLOptions { return self(1 << 0) }
    static var AnchorTags:       WPHTMLOptions { return self(1 << 1) }
    static var UnorderedList:    WPHTMLOptions { return self(1 << 2) }
    static var OrderedList:      WPHTMLOptions { return self(1 << 3) }
    static var DescriptionList:  WPHTMLOptions { return self(1 << 4) }
    static var Blockquotes:      WPHTMLOptions { return self(1 << 5) }
    static var CodeSamples:      WPHTMLOptions { return self(1 << 6) }
    static var Headers:          WPHTMLOptions { return self(1 << 7) }
    static var AllCaps:          WPHTMLOptions { return self(1 << 8) }
    static var Prude:            WPHTMLOptions { return self(1 << 9) }

    private enum Feature: String {
        case Links = "link"
        case Emphasis = "decorate"
        case UnorderedList = "u1"
        case OrderedList = "o1"
        case DescriptionList = "d1"
        case Blockquotes = "bq"
        case CodeSamples = "code"
        case Headers = "headers"
        case AllCaps = "allcaps"
        case PrudeText = "prude"
    }

    public func toMaskString() -> String {
        var optionsString: String = ""

        if (self & .AnchorTags) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Links.toRaw())
        }
        if (self & .EmphasisTags) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Emphasis.toRaw())
        }
        if (self & .UnorderedList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.UnorderedList.toRaw())
        }
        if (self & .OrderedList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.OrderedList.toRaw())
        }
        if (self & .DescriptionList) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.DescriptionList.toRaw())
        }
        if (self & .Blockquotes) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Blockquotes.toRaw())
        }
        if (self & .CodeSamples) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.CodeSamples.toRaw())
        }
        if (self & .Headers) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.Headers.toRaw())
        }
        if (self & .AllCaps) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.AllCaps.toRaw())
        }
        if (self & .Prude) {
            optionsString = optionsString.stringByAppendingPathComponent(Feature.PrudeText.toRaw())
        }

        return optionsString
    }
}

public class Wallpaper: NSObject {

    private class func requestImage(path: String, size: CGSize, completion: (image: UIImage?) -> ()) {
        let screenScale: CGFloat = UIScreen.mainScreen().scale

        let urlString = NSString(format: path, "\(Int(size.width * screenScale))", "\(Int(size.height * screenScale))")
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data, scale: screenScale)
                completion(image: image);
            } else {
                println("++ Wallpaper Error: \(error)")
                completion(image: nil)
            }
        }
    }
}

//MARK: - Images
public extension Wallpaper {

    public class func placeKittenImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceKitten.toRaw(), size: size, completion: completion)
    }

    public class func placeKittenGreyscaleImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceKittenGreyscale.toRaw(), size: size, completion: completion)
    }

    public class func placeBaconImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Bacon.toRaw(), size: size, completion: completion)
    }

    public class func placeHolderImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.PlaceHolder.toRaw(), size: size, completion: completion)
    }

    public class func placeRandomImage(size: CGSize, category: String, completion: (image: UIImage?) -> ()) {
        let path = WallpaperImageURLString.Random.toRaw().stringByAppendingPathComponent(category)
        requestImage(path, size: size, completion: completion)
    }

    public class func placeRandomGreyscaleImage(size: CGSize, category: String, completion: (image: UIImage?) -> ()) {
        let path = WallpaperImageURLString.RandomGreyscale.toRaw().stringByAppendingPathComponent(category)
        requestImage(path, size: size, completion: completion)
    }

    public class func placeRandomImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Random.toRaw(), size: size, completion: completion)
    }

    public class func placeRandomGreyscaleImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.RandomGreyscale.toRaw(), size: size, completion: completion)
    }

    public class func placeDowneyImage(size: CGSize, completion: (image: UIImage?) -> ()) {
        requestImage(WallpaperImageURLString.Downey.toRaw(), size: size, completion: completion)
    }
}


//MARK: - Text
public extension Wallpaper {

    public class func placeText(numberOfParagraphs: Int, paragraphLength: WPTextParagraphLength, textOptions: WPTextOptions, completion: (placeText: String?) -> ()) {
        assert(numberOfParagraphs > 0, "Number of paragraphs is invalid")

        var urlString = kWPPlaceRandomTextURLString.stringByAppendingString(textOptions.toMaskString())
        urlString = urlString.stringByAppendingPathComponent("plaintext")
        urlString = urlString.stringByAppendingPathComponent(paragraphLength.toRaw())

        let paragraphArgs = "\(numberOfParagraphs)"
        urlString = urlString.stringByAppendingPathComponent(paragraphArgs)
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url)
         NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let returnString = NSString(data: data, encoding: NSUTF8StringEncoding)
                completion(placeText: returnString)
            } else {
                println("++ Wallpaper Error: \(error)")
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
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: nil) as NSDictionary
                let returnString = dict["text"] as String
                completion(hipsterIpsum: returnString)
            } else {
                println("++ Wallpaper Error: \(error)")
                completion(hipsterIpsum: nil)
            }
        }
    }

    public class func placeHTML(numberOfParagraphs: Int, paragraphLength: WPTextParagraphLength, options: WPHTMLOptions, completion: (placeText: String?) -> ()) -> () {
        let htmlURL = placeURLForHTML(numberOfParagraphs, paragraphLength: paragraphLength, htmlOptions: options)
        let request = NSURLRequest(URL: htmlURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if error == nil {
                let returnString = NSString(data: data, encoding: NSUTF8StringEncoding)
                completion(placeText: returnString)
            } else {
                println("++ Wallpaper Error: \(error)")
                completion(placeText: nil)
            }
        }
    }

    public class func placeURLForHTML(paragraphs: Int, paragraphLength: WPTextParagraphLength, htmlOptions: WPHTMLOptions) -> NSURL {
        var htmlURLString = kWPPlaceRandomTextURLString
        let optionsString = htmlOptions.toMaskString()

        htmlURLString = htmlURLString.stringByAppendingPathComponent(paragraphLength.toRaw())
        htmlURLString = htmlURLString.stringByAppendingPathComponent(optionsString)

        return NSURL(string: htmlURLString)
    }
}

//MARK: - Colors
public extension Wallpaper {

    public class func placeRandomColorWithHue(hue: CGFloat) -> UIColor {
        assert(hue <= 1 && hue >= 0, "Hue value must be between 0 and 1")

        let s = randomPercentage(NSMakeRange(10, 90))
        let b = randomPercentage(NSMakeRange(10, 90))

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
