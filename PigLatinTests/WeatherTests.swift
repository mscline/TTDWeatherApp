//
//  WeatherTests.swift
//  PigLatin
//
//  Created by Monsoon Co on 6/25/15.
//  Copyright (c) 2015 Monsoon. All rights reserved.
//

import UIKit
import XCTest
import Nimble

class WeatherTests: XCTestCase {


    // MARK: url connection
    
    func test_validateZipCode() {
        
        expect(Weather.validateZipCode(zip: "12345")).to(equal(true))
        
    }

    func test_validateZipCode_fail() {
        
        expect(Weather.validateZipCode(zip: "1234")).to(equal(false))
        
    }

    func test_getAppropriateURL_useCached(){
        
        expect(Weather.getAppropriateURL(zip: "94596", usedCachedData: true)).to(equal(helper_returnNSURLForCashedData()))

    }
    
    func test_getAppopriateURL_forWeb(){

        var url = "http://api.openweathermap.org/data/2.5/weather?zip=94596,us"
        var nsurl = NSURL(string: url)
        
        expect(Weather.getAppropriateURL(zip: "94596", usedCachedData: false)).to(equal(nsurl))
    }
    
    func test_downloadWeatherForZip_sampleData(){
        
        // SHOUDL FAIL!!!
        
        Weather.downloadWeatherForZip(zip: "94040", usedCachedData: true) { (weatherObject) -> () in
            
            expect(weatherObject).toEventuallyNot(beNil(), timeout: 1.0, pollInterval: 0.1)
        }

    
    }
    
    
    // MARK: parseURLData
    
    func test_parseURLData(){
    
        let sampleData = helper_getSampleDataFromBundleWithFileName("sampleData_noNotifications")
        
        let weatherObject = Weather.parseData(sampleData)

        expect(weatherObject?.temperature).to(equal(350.68))
        expect(weatherObject?.dailyWeather).to(equal("xxxx"))
        expect(weatherObject?.dailyWeatherDetail).to(equal("Green Skies"))
        
    }
    
    func test_parseURLData_failBecauseOfMissingKey(){
        
        let sampleData = helper_getSampleDataFromBundleWithFileName("missingData")
        
        let weatherObject = Weather.parseData(sampleData)

        expect(weatherObject?.temperature).to(beNil())
        expect(weatherObject?.dailyWeather).to(beNil())
        expect(weatherObject?.dailyWeatherDetail).to(beNil())
    }
    
    func helper_getSampleDataFromBundleWithFileName(fileName:String) -> NSData {
    
        let path:String = NSBundle.mainBundle().pathForResource(fileName, ofType: "txt")!
        let nsurl = NSURL(fileURLWithPath: path, isDirectory: false)
        let request = NSURLRequest(URL: nsurl!)
        
        var response:NSURLResponse?
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil)
     
        return data!
    }
    
    func test_addTimeStamp_locally() {
    
        let weatherObj = Weather()
        Weather.addTimeStamp(weatherObj: weatherObj)
        
        let savedTimeInterval = Int(weatherObj.downloadedOnDate!.timeIntervalSince1970)
        let expectedTimeInterval = Int(NSDate().timeIntervalSince1970)
        
        expect(savedTimeInterval).to(equal(expectedTimeInterval))
    
    }

    func test_addTimeStamp_saveToDisk() {
        
        // ??? should write test, just calls test that I already wrote?
        // only check to make sure that the method is actually run ???
        
    }
    
    
    // MARK: TEMPATURE UNIT CONVERSIONS
    
    func test_returnTempInDesiredUnits_testKelvin(){
    
        expect(Weather.returnTempInDesiredUnits(DegreesIn.K, tempInKelvin: 100)).to(equal("100"))
        
    }
    
    func test_returnTempInDesiredUnits_testC(){
        
        expect(Weather.returnTempInDesiredUnits(DegreesIn.C, tempInKelvin: 273.15)).to(equal("0"))
        
    }
    
    
    func test_returnTempInDesiredUnits_testF(){
        
        expect(Weather.returnTempInDesiredUnits(DegreesIn.F, tempInKelvin: 273.15)).to(equal("32"))
        
    }
    
    func test_returnTemperatureInCelsius(){
    
        expect(Weather.returnTemperatureInCelsius(temperatureInKelvin:373.15)).to(equal(100))
        
    }

    func test_returnTemperatureInKelvin(){
        
        expect(Weather.returnTemperatureInF(temperatureInKelvin: 273.15)).to(equal(32.0))
        
    }
    
    
    // MARK: SAVING TO FILE
    
    // overwrite cached data ???
    // time commitment ???
    
    func test_saveLastDownloadedDate_inSecondsFrom1970_inUserDefaults(){
        
        Weather.saveDownloadedDate_inSecondsFrom1970_inUserDefaults(secondsSince1970:2.7)

        // now retrive data
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let interval:Double? = userDefaults.valueForKey("lastDownload") as? Double
        
        expect(interval).to(equal(2.7))
        
    }
    
    func test_loadLastDownloadedDate_inSecondsFrom1970_fromUserDefaults() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(11.1, forKey: "lastDownload")
        userDefaults.synchronize()
        
        expect(Weather.loadLastDownloadedDate_inSecondsFrom1970_fromUserDefaults()).to(equal(11.1))
        
    }
    
    // just repeating the code ???  brittle
    func test_returnNSURLForCachedData() {
        
        expect(self.helper_returnNSURLForCashedData()).to(equal(Weather.returnNSURLForCachedData()))
    }
    
    // TEST NOT SETUP CORRECTLY ???
    
    func test_cacheWeatherJSONFile_akaSaveIt() {
        
        // save sample data
        let array = "a test"
        let data = NSJSONSerialization.dataWithJSONObject(array, options: NSJSONWritingOptions.allZeros, error: nil)
        Weather.cacheWeatherJSONFile_akaSaveIt(data!)
        
        
        // load data
      //  let request = NSURLRequest(URL: helper_returnNSURLForCashedData())
        
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, err) -> Void in
//            
//            let arry:NSArray? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSArray
        
          //  expect(arry).toNot(beNil())
          //  expect(arry?.count) > 0
//            
//            let str = arry![0] as? String
//            expect(str).to(equal("a test"))
//            expect(str).toEventually(equal("a test"), timeout: 2.0, pollInterval: 1.0)
  //      }
        
    }
    
    func helper_returnNSURLForCashedData() -> NSURL {
    
        let fileMgr = NSFileManager.defaultManager()
        
        let documentDirectoryPath : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as! String
        let filePath = documentDirectoryPath + "/weatherJSON"
        var destinationPath = NSURL(fileURLWithPath: filePath)
        
        return destinationPath!
    }
    
    
    // MARK: data downloaded
    
    func confirmDataPutOnScreen(){
    
        // can't check screen unless vc is loaded...
    }
    
    

}
