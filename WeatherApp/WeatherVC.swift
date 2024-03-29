//
//  WeatherVC.swift
//  WeatherApp
//
//  Created by Humbelani Mdau on 2017/07/31.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyGif

class WeatherVC: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypeLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var currentWeather: CurrentWeather!
    var forecasts = [Forecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        collectionView.delegate = self
        collectionView.dataSource = self
        currentWeather = CurrentWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.contentSize = CGSize(width: view.frame.size.width,height: (collectionView.frame.origin.y + collectionView.frame.size.height))
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            if let longitude = currentLocation?.coordinate.longitude {
                Location.sharedInstance.longitude = longitude
            } else {
                Location.sharedInstance.longitude = 28.056702
            }
            if let latitude = currentLocation?.coordinate.latitude {
                Location.sharedInstance.latitude = latitude
            } else {
                Location.sharedInstance.latitude = -26.107567
            }
            //Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            //Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            print("LOCATIONNNNNNNNNNNNNN \(currentLocation?.coordinate.latitude, currentLocation?.coordinate.longitude)")
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    self.updateMainUI()
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    func downloadForecastData(completed: @escaping DownloadComplete) {
        let forecastURL = URL(string: FORECAST_URL)!
        
        Alamofire.request(forecastURL).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                        print(obj)
                    }
                    self.forecasts.remove(at:0)
                    self.collectionView.reloadData()
                }
            }
            completed()
        }
    }
    
    func updateMainUI() {
        dateLabel.text = currentWeather.date
        let currentTemp = String(format: "%.0f",currentWeather.currentTemp)
        let minTemp = String(format: "%.0f",currentWeather.minTemp)
        let maxTemp = String(format: "%.0f",currentWeather.maxTemp)
        let humidity = String(format: "%.0f",currentWeather.humidity)
        let wind = String(format: "%.0f",currentWeather.wind)
        let cloudsCover = String(format: "%.0f",currentWeather.cloudsCover)
        currentTempLabel.text = "\(currentTemp)°"
        currentWeatherTypeLabel.text = currentWeather.weatherType
        locationLabel.text = currentWeather.cityName
        currentWeatherImage.image = UIImage(named:currentWeather.weatherType)
        minTempLabel.text = "L: \(minTemp)°"
        maxTempLabel.text = "H: \(maxTemp)°"
        humidityLabel.text = "Humidity: \(humidity)%"
        cloudCoverLabel.text = "Clouds Cover: \(cloudsCover)%"
        sunsetLabel.text = "\(currentWeather.sunset)"
        sunriseLabel.text = "\(currentWeather.sunrise)"
        windSpeedLabel.text = "Wind: \(wind) km/h"

 
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? ForecastCollectionCell {
                let forecast = forecasts[indexPath.row]
                cell.configureCollectionCell(forecast: forecast)
            return cell
        } else{
            return ForecastCollectionCell()
        }
        
    }
    
}

