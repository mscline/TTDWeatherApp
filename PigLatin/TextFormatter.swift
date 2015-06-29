//
//  TextFormatter.swift
//  BlogSplitScreenScroll
//
//  Created by xcode on 1/9/15.
//  Copyright (c) 2015 MSCline. All rights reserved.
//


import UIKit

class TextFormatter: NSObject {


    class func createAttributedString(text: NSString, withFont: String?, fontSize:CGFloat?, fontColor:UIColor?, nsTextAlignmentStyle:NSTextAlignment?) -> (NSAttributedString)
    {

        // create attributed string to work with
        let artString = NSMutableAttributedString(string: text as String)

        // check to make sure have all our values
        if (text == ""){ return artString;}

        let theFont = withFont ?? "Palatino-Roman"
        let theFontSize = fontSize ?? 12.0
        let theFontColor = fontColor ?? UIColor.blackColor()
        let textAlignmentStyle = nsTextAlignmentStyle ?? NSTextAlignment.Left

        // prep work - build font, paragraph style, range
        let fontX = UIFont(name: theFont, size: theFontSize) ?? UIFont(name: "Palatino-Roman", size: 12.0)
        let artStringRange = NSMakeRange(0, artString.length) ?? NSMakeRange(0, 0)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignmentStyle;

        // set attributes
        artString.addAttribute(NSFontAttributeName, value:fontX!, range: artStringRange)
        artString.addAttribute(NSForegroundColorAttributeName, value:theFontColor, range: artStringRange)
        artString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range: artStringRange)

        return artString;

    }

    class func combineAttributedStrings(arrayOfAttributedStrings:Array<NSAttributedString>) -> (NSAttributedString)
    {

        let artString = NSMutableAttributedString()

        for insertMe:NSAttributedString in arrayOfAttributedStrings {

            artString.appendAttributedString(insertMe)

        }
    
        return artString;
    
    }

    class func returnHeightOfAttributedStringGivenFixedHeightOrWidth(attributedString attrString: NSAttributedString!, maxWidth:CGFloat!, maxHeight: CGFloat!) -> (CGFloat) {

        let maxWidth = maxWidth
        let maxHeight = maxHeight
        var desiredFrameHeight = attrString.boundingRectWithSize(CGSizeMake(maxWidth, maxHeight), options:NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size.height

        // ??? NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading

        return desiredFrameHeight
    }

    class func printListOfFontFamilyNames(){

        println(UIFont.familyNames())

    }
    

}






