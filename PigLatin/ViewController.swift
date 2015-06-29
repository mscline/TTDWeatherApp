//
//  ViewController.swift
//  PigLatin
//
//  Created by Hector on 6/24/15.
//  Copyright (c) 2015 Monsoon. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
        var weatherObject: Weather?
        var showTemperatureInUnits = DegreesIn.F
    
        @IBOutlet weak var labelTemperature: UILabel!
        @IBOutlet weak var labelDescription: UILabel!
        @IBOutlet weak var labelMessage: UILabel!
        @IBOutlet weak var textBox: UITextField!
        @IBOutlet weak var buttonGo: UIButton!
        @IBOutlet weak var picker: UIPickerView!
        @IBOutlet weak var backgroundImageView: UIImageView!
    
        var defaultAlphaOfMainView:CGFloat = 0.6
    
    
    // MARK: LIFECYCLE AND SETUP
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setDisplaySettings()
        ifNoDataLoadCachedDataLoadFromFile()
        refreshDataIfCachedDataExpired()
        setupTimerToCheckForNewDataEveryXMin(15.0)

    }

    func setDisplaySettings(){
        
        picker.selectRow(1, inComponent: 0, animated: false)
        
        backgroundImageView.image = UIImage(named: "sunny.jpg")
        self.view.backgroundColor = UIColor.blackColor()
        backgroundImageView.alpha = 0.4
        
        textBox.alpha = defaultAlphaOfMainView
        buttonGo.alpha = 0.7
        
    }
    
    func setupTimerToCheckForNewDataEveryXMin(min:Double) {
        
        let fireEveryXSeconds = min * 60.0
        let timer = NSTimer.scheduledTimerWithTimeInterval(fireEveryXSeconds, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: true)
        
    }
    
    func timerFired(){
        
        refreshDataIfCachedDataExpired()
    }
    
    
    // MARK: CACHING
    
    func ifNoDataLoadCachedDataLoadFromFile()
    {
        // load from file
        if weatherObject == nil {
        
            getData(usedCachedData: true)
            
        }
    }
    
    func refreshDataIfCachedDataExpired() -> Bool{
    
        var elapsedTime:Double?
        
        // check to see how long ago data downloaded
        if weatherObject?.downloadedOnDate?.timeIntervalSince1970 == nil {
        
            // load data from user defaults
            elapsedTime = Weather.loadLastDownloadedDate_inSecondsFrom1970_fromUserDefaults()
        
        }

        // if downloaded less than 15 min ago download (900 seconds) exit
        
        if elapsedTime != nil {
        
            var secSince1970 = NSDate().timeIntervalSince1970
            var timeElapsed = secSince1970 - elapsedTime!

            if timeElapsed < 900 { return false; }
            
        }
        
        // download data from web
        getData(usedCachedData: false)
        
        return true
    }
    
    func getData(#usedCachedData:Bool){
        
        changeAlpha(value: 0.2, time: 1.0)
        
        Weather.downloadWeatherForZip(zip: textBox.text, usedCachedData: usedCachedData, completionBlock: { (weatherObject) -> () in
        
            self.weatherObject = weatherObject
            self.putDataOnScreen(weatherDataObject: weatherObject)
            self.changeAlpha(value: self.defaultAlphaOfMainView, time: 1.0)
            
        })
        
    }
    
    func changeAlpha(#value:CGFloat, time:Double){
    
        UIView.animateWithDuration(time, animations: { () -> Void in
            
            self.view.alpha = value
        })
    }
    
    // MARK: ACTIONS
    
    @IBAction func goButtonPressed(sender: AnyObject) {
    
        updateWeather()
    }
    
    @IBAction func returnButtonPressed(sender: AnyObject) {

        updateWeather()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        showTemperatureInUnits = pickerOptions[row]
        putDataOnScreen(weatherDataObject: weatherObject)
        
    }
    
    func updateWeather(){
        
        // get zip code from text box and download data for that key
        
        // check to see if zip valid (or don't release keyboard)
        if !Weather.validateZipCode(zip: textBox.text) {
            
            return  
        }

        textBox.resignFirstResponder()

        // if zip changed, download new data
        getData(usedCachedData: false)
        
    }
    
    
    //MARK: PRESENT DATA
    
    func putDataOnScreen(#weatherDataObject:Weather?){
    
        // display temperature or show nothing (just return)
        if weatherObject == nil || weatherDataObject!.temperature == nil {

            labelTemperature.attributedText = nil
            return;
        }
        
        // build attributed string and display
        let textToDisplay = Weather.returnTempInDesiredUnits(showTemperatureInUnits, tempInKelvin: weatherDataObject!.temperature!) + ""
        let artString = TextFormatter.createAttributedString(textToDisplay, withFont: "Papyrus", fontSize: 100, fontColor: UIColor.whiteColor(), nsTextAlignmentStyle: NSTextAlignment.Center)
        
        labelTemperature.attributedText = artString
        
        // display detailed report
        let weatherDetail = weatherObject?.dailyWeatherDetail ??  ""
        var attributedDescription = TextFormatter.createAttributedString(weatherDetail, withFont: "chalkduster", fontSize: 16, fontColor: UIColor.whiteColor(), nsTextAlignmentStyle: NSTextAlignment.Center)
        labelDescription.attributedText = attributedDescription
        
        // display weather alerts
        let messageToUser = compileWeatherAlerts(weatherDataObject: weatherDataObject)
        var attributedMessage = TextFormatter.createAttributedString(messageToUser, withFont: "chalkduster", fontSize: 16, fontColor: UIColor.whiteColor(), nsTextAlignmentStyle: NSTextAlignment.Center)
        
        // background image
        ifRainingSetBackgroundImage(weatherDataObject: weatherObject)
        ifSunnyChangeBackgroundImage(weatherDataObject: weatherObject)
        
        labelMessage.attributedText = attributedMessage
    
    }
    
    func compileWeatherAlerts(#weatherDataObject:Weather?) -> String {
    
        let str =  ifColdTellUserToWearJacket(weatherDataObject: weatherDataObject) +
            ifRainingTellToBringUmbrella(weatherDataObject: weatherDataObject) +
            ifSunnyTellWearSunscreenh(weatherDataObject: weatherDataObject) + ""
        
        return str
    }
    
    func ifColdTellUserToWearJacket(#weatherDataObject:Weather?) -> String {

        if let temp = weatherDataObject?.temperature  {
            
            if temp < 278 {
        
                return "It is cold outside.  Don't forget your jacket."
                
            }
        }
        
        return ""
    
    }
    
    func ifRainingTellToBringUmbrella(#weatherDataObject:Weather?) -> String {

        if let weather = weatherDataObject?.dailyWeather {
        
            if weather == "Rain" { return "It is raining outside.  Don't forget your umbrella.";}
        
        }
        
        return ""
        
    }
    
    func ifSunnyTellWearSunscreenh(#weatherDataObject:Weather?) -> String {
       
        if let weather = weatherDataObject?.dailyWeather {
            
            if weather == "Clear" { return "\"It is sunny out, don't forget your sunscreen.\"";}
            
        }
        
        return ""
        
    }
    
    func ifRainingSetBackgroundImage(#weatherDataObject:Weather?){
        
        if let weather = weatherObject?.dailyWeather {
            
            if weather == "Rain" { backgroundImageView.image = UIImage(named: "rain.jpg") }
        }
        
    }
    
    func ifSunnyChangeBackgroundImage(#weatherDataObject:Weather?)  {
        
        if let weather = weatherObject?.dailyWeather {
            
            backgroundImageView.image = UIImage(named: "sunny.jpg")
            
        }
        
    }
    
    // MARK: PICKER DATA SOURCE
    
    var pickerOptions = [DegreesIn.C, DegreesIn.F, DegreesIn.K]
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerOptions.count
    
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
    
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return pickerView.frame.height / 3.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return pickerView.frame.width
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let artString = TextFormatter.createAttributedString(pickerOptions[row].description(), withFont: "papyrus", fontSize: 20, fontColor: UIColor.whiteColor(), nsTextAlignmentStyle: NSTextAlignment.Center)
        
        return artString
    }
    

}

