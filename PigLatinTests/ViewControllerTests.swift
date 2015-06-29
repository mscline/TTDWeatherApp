//
//  ViewControllerTests.swift
//  PigLatin
//
//  Created by Monsoon Co on 6/25/15.
//  Copyright (c) 2015 Monsoon. All rights reserved.
//

import UIKit
import XCTest
import Nimble


// MARK: FAKE VC - FOR STUBS

class FakeVC: ViewController {
    
    
        var timerDidFire:Bool = false
    
    
    override func ifColdTellUserToWearJacket(#weatherDataObject:Weather?) -> String {
        
        return "a"
        
    }
    
    override func ifRainingTellToBringUmbrella(#weatherDataObject:Weather?) -> String {
        
        return "b"
        
    }
    
    override func ifSunnyTellWearSunscreenh(#weatherDataObject:Weather?) -> String {
        
        return "c"
        
    }
    
    override func timerFired(){

        timerDidFire = true
    }
    
}


// MARK: TESTS

class ViewControllerTests: XCTestCase {

    var vc = ViewController()
    var fakeVC = FakeVC()
    var weatherObj:Weather?
    
    override func setUp() {
        super.setUp()
        
        weatherObj = Weather()
        weatherObj?.temperature = 277 // in Kelvin
        weatherObj?.dailyWeather = "Clear"
        weatherObj?.dailyWeatherDetail = "Sunshine and Spring"
    
    }
    
    func test_ifColdTellUserToWearJacket() {
        
        let str = self.vc.ifColdTellUserToWearJacket(weatherDataObject: self.weatherObj)
        expect(str).to(equal("It is cold outside.  Don't forget your jacket."))
        
    }
    
    func test_ifRainingTellToBringUmbrella() {
        
        self.weatherObj?.dailyWeather = "Rain"
        expect(self.vc.ifRainingTellToBringUmbrella(weatherDataObject: self.weatherObj)).to(equal("It is raining outside.  Don't forget your umbrella."))
        
    }
    
    func test_ifSunnyTellWearSunscreenh() {
        
        expect(self.vc.ifSunnyTellWearSunscreenh(weatherDataObject: self.weatherObj)).to(equal("\"It is sunny out, don't forget your sunscreen.\""))
    }
    
    // ?? can set this to run after and then use the results of smaller methods or should use stubs ???
    // ?? this is a little funky because I have to know which methods are called internally, so not just checking input / output
    func test_compileWeatherAlerts(#weatherDataObject:Weather?) {
        
        expect(self.fakeVC.compileWeatherAlerts(weatherDataObject: self.weatherObj)).to(equal("abc"))
    }

    
    // MARK: CACHING
    
    func test_setupTimerToCheckForNewDataEveryXMin() {
        
        fakeVC.setupTimerToCheckForNewDataEveryXMin(0.001)
        expect(self.fakeVC.timerDidFire).toEventually(equal(true), timeout: 0.2, pollInterval: 0.1)
    }
  
    func test_refreshDataIfCachedDataExpire_noWeatherObj_pass(){
  
        weatherObj = nil
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(NSDate().timeIntervalSince1970 - 901, forKey: "lastDownload")
        userDefaults.synchronize()
        
        // hmmm... changed our method to return a bool to know if will refresh so can test it
        // should change code, or test differently?
        let didRun = vc.refreshDataIfCachedDataExpired()
        
        expect(didRun).to(equal(true))
    }

}

/*
    // INJECTION: if we wanted to check to see if the getData method of our VC calls the download method in Weather, we could try to write a FakeWeather subclass which will set a bool to tell us when someone ran it, but the problem is, the VC is calling the Weather class, not the FakeWeather class.  This is why we use code injection (or maybe swizzling).  That way we can supply the class we want to run.

*/



