//
//  DetailsVC.swift
//  WeatherApp
//
//  Created by Batuhan Erdem on 21.01.2025.
//

import UIKit
import CoreLocation
class DetailsVC: UIViewController,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    
    
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var cityText: UITextField!
    
    @IBOutlet weak var humidityLabel: UILabel!
   
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first{
            locationManager.stopUpdatingLocation()
            onLocationUpdate?(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Konum alınamadı: \(error.localizedDescription)")
        }
    
    
    @IBAction func weatherForecastButton(_ sender: Any) {
        guard let city = cityText.text, !city.isEmpty else {
               makeAlert(title: "Error", message: "Please enter a city name.")
               return
           }
           
           let apiKey = "e9b5b0583615aa9a106089c2613ed70f"
           let urlString = "http://api.weatherstack.com/current?access_key=\(apiKey)&query=\(city)"
           
           guard let url = URL(string: urlString) else {
               makeAlert(title: "Error", message: "Invalid URL.")
               return
           }
           
           let session = URLSession.shared
           let task = session.dataTask(with: url) { data, response, error in
               if let error = error {
                   DispatchQueue.main.async {
                       self.makeAlert(title: "Error", message: error.localizedDescription)
                   }
                   return
               }
               
               guard let data = data else {
                   DispatchQueue.main.async {
                       self.makeAlert(title: "Error", message: "No data received.")
                   }
                   return
               }
               
               do {
                   if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let current = json["current"] as? [String: Any],
                      let temperature = current["temperature"] as? Int,
                      let humidity = current["humidity"] as? Int,
                      let windSpeed = current["wind_speed"] as? Int,
                      let weatherDescriptions = current["weather_descriptions"] as? [String],
                      let weatherDescription = weatherDescriptions.first,
                      let iconUrl = current["weather_icons"] as? [String],
                      let iconUrlString = iconUrl.first {
                       
                       // UI Güncellemesi
                       DispatchQueue.main.async {
                           self.temperatureLabel.text = "Temperature: \(temperature)°C"
                           self.humidityLabel.text = "Humidity: \(humidity)%"
                           self.windSpeedLabel.text = "Wind: \(windSpeed) km/h"
                           self.cityLabel.text = city
                           
                           let dateFormatter = DateFormatter()
                               dateFormatter.dateStyle = .full
                               let currentDate = dateFormatter.string(from: Date())
                               self.dayLabel.text = currentDate
                           
                           // Resim İndir
                           if let imageUrl = URL(string: iconUrlString) {
                               if let imageData = try? Data(contentsOf: imageUrl) {
                                   self.weatherImageView.image = UIImage(data: imageData)
                               }
                           }
                       }
                   } else {
                       DispatchQueue.main.async {
                           self.makeAlert(title: "Error", message: "Invalid response format.")
                       }
                   }
               } catch {
                   DispatchQueue.main.async {
                       self.makeAlert(title: "Error", message: "JSON parsing error: \(error.localizedDescription)")
                   }
               }
           }
        task.resume()
    }
    
    
    func makeAlert(title:String,message:String){
        let alert = UIAlertController(title: "Error", message: message , preferredStyle: UIAlertController.Style.alert)
        
        let okButtton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(okButtton)
        self.present(alert, animated: true, completion: nil)
    }
}
