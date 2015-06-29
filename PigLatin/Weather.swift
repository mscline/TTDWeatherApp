//
//  Weather.swift
//  PigLatin
//
//  Created by Monsoon Co on 6/25/15.
//  Copyright (c) 2015 Monsoon. All rights reserved.
//

import UIKit


enum DegreesIn {
    
    case K, F, C
    
    func description() -> String {
        switch self {
        case K: return "°K"
        case F: return "°F"
        case C: return "°C"
        }
    }
}


class Weather {
   
    
        var temperature:Double?
        var dailyWeather:String?
        var dailyWeatherDetail:String?
        var downloadedOnDate:NSDate?
    
    
    class func validateZipCode(#zip:String?) -> Bool {
    
        if zip != nil {
            
            if count(zip!) == 5 {return true;}
        }
        
        return false
    }
    
    class func downloadWeatherForZip(#zip:String, usedCachedData:Bool, completionBlock:(weatherObject:Weather?)->()) {

        
        let nsurl = getAppropriateURL(zip: zip, usedCachedData: usedCachedData)
        if nsurl == nil { println("url error"); return;}
        
        let request = NSURLRequest(URL: nsurl!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, err) -> Void in
            
            let weather = self.dataDownloadFinished(data: data, usingCachedData: usedCachedData)
            completionBlock(weatherObject: weather)
        }
    }
    
    class func getAppropriateURL(#zip:String, usedCachedData:Bool) -> NSURL? {
    
        // options: 1) use cached data 2) download 3) from bundle (for unit testing)
        
        var nsurl:NSURL?
        
        if usedCachedData {
            
            nsurl =  Weather.returnNSURLForCachedData()
            
        } else {
            
            var url = "http://api.openweathermap.org/data/2.5/weather?zip=" + zip + ",us"
            nsurl = NSURL(string: url)
            nsurl = changeURLifRunningTests(oldURL: nsurl)
            
        }
        
        return nsurl
        
    }
    
    class func changeURLifRunningTests(#oldURL:NSURL?) -> NSURL? {
    
        var nsurl = oldURL
        
        // not being used for unit testing (tests will access bundle themselves), but may want for functional
        

    //        #if DEBUG
    //
    //            let processStateDict = NSProcessInfo.processInfo().environment as Dictionary
    //            let isPerformingUnitTest:Bool = processStateDict["XCInjectBundle"] as! Bool
    //
    //            if isPerformingUnitTest {
    //
    //                  let path:String = NSBundle.mainBundle().pathForResource("sampleData_sunny", ofType: "txt")!
    //                  nsurl = NSURL(fileURLWithPath: path, isDirectory: false)
    //            }
    //
    //        #endif
        
        return nsurl
    
    }
    
    class func dataDownloadFinished(#data:NSData?, usingCachedData:Bool) -> Weather? {
    
        if data == nil { println("no data"); return nil;}
        
        // parse data
        let weather = self.parseData(data!)
        
        // if new data, save json file for caching and save time stamp
        if usingCachedData == false {
            
            addTimeStamp(weatherObj: weather!)
            self.cacheWeatherJSONFile_akaSaveIt(data!)
        }
        

        return weather
    }
    
    class func addTimeStamp(#weatherObj:Weather!){
        
        weatherObj!.downloadedOnDate = NSDate()
        saveDownloadedDate_inSecondsFrom1970_inUserDefaults(secondsSince1970: weatherObj!.downloadedOnDate!.timeIntervalSince1970)
        
    }
    
    class func parseData(data:NSData) -> Weather? {
    
        let dataDict:AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        if dataDict == nil { println("no data"); return nil;}

        var weatherObject = Weather()
        
        if let dict = dataDict as? NSDictionary {
            
            // save temp: ["main"]["temp"]
            if let subDict = dict["main"] as? NSDictionary {
                
                let temperature = subDict["temp"] as? Double
            
                weatherObject.temperature = temperature
            
            }
            
            // save weather main ["weather"][0]["main"] & description: ["weather"][0]["description"]
            if let arry = dict["weather"] as? NSArray {
            
                if arry.count > 0 {
                
                    if let dict = arry[0] as? NSDictionary {
                    
                        if let dailyWeather = dict["main"] as? String {
                            
                            weatherObject.dailyWeather = dailyWeather
                        }
                        
                        if let descriptionW = dict["description"] as? String {

                            weatherObject.dailyWeatherDetail = descriptionW
                        }
                    }
                }
            
            }
            
        }
        
        return weatherObject
        
    }

    
    // MARK: TEMPERATURE CONVERSIONS
    
    class func returnTempInDesiredUnits(tempUnits:DegreesIn, tempInKelvin:Double) -> String {
    
        var tempAsNumber:Double = 0
        
        switch tempUnits{
        case DegreesIn.K : tempAsNumber = tempInKelvin
        case DegreesIn.C : tempAsNumber = returnTemperatureInCelsius(temperatureInKelvin: tempInKelvin)
        case DegreesIn.F : tempAsNumber = returnTemperatureInF(temperatureInKelvin: tempInKelvin)
        }
        
        let tempAsString = "\(Int(tempAsNumber))"
        return tempAsString
    }
    
    class func doNothing(){}
    
    class func returnTemperatureInCelsius(#temperatureInKelvin:Double) -> Double {
    
        return (temperatureInKelvin - 273.15)
        
    }
    
    class func returnTemperatureInF(#temperatureInKelvin:Double) -> Double {
        
        return (temperatureInKelvin - 273.15) * 1.8 + 32.0
        
    }
    
    
    // MARK: ARCHIVE IN USER DEFAULTS
    
    // ??? running tests clears cache, should use different directory?/keys?
    
    class func saveDownloadedDate_inSecondsFrom1970_inUserDefaults(#secondsSince1970:Double){
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(secondsSince1970, forKey: "lastDownload")
        userDefaults.synchronize()

    }
    
    class func loadLastDownloadedDate_inSecondsFrom1970_fromUserDefaults() -> Double {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let interval:Double = userDefaults.valueForKey("lastDownload") as? Double ?? 0.0
        
        return interval
    }
    
    class func cacheWeatherJSONFile_akaSaveIt(json:NSData){
    
        let destinationPath = returnNSURLForCachedData()
        json.writeToURL(destinationPath, atomically: true)
        
    }
    
    class func returnNSURLForCachedData() -> NSURL {
     
        let fileMgr = NSFileManager.defaultManager()
        
        let documentDirectoryPath : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as! String
        let filePath = documentDirectoryPath + "/weatherJSON"
        var destinationPath = NSURL(fileURLWithPath: filePath)
        //  println("\(destinationPath!)")
    
        return destinationPath!
    }
    
    
    
}






