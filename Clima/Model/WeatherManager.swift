//
//  WeatherManager.swift
//  Clima
//
//  Created by weijie diao on 1/20/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weatherModel: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=cebd0400eac4989317145245bd09b159&units=metric"
    
    var delegate: WeatherManagerDelegate?
        
    func fetchWeather(cityName: String){
        let urlString = weatherURL + "&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = weatherURL + "&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        // Create a URL object
        let url = URL(string: urlString)
        if url == nil {
            return
        }
        let safeUrl = url!
        
        // Create a URL Session => Open a browser
        let session = URLSession(configuration: .default)
        
        // Give URL Session a task => Enter the url into the search bar
        let task = session.dataTask(with: safeUrl, completionHandler: handle(data:response:error:))
        
        // Start the task => Hit enter in the search bar
        task.resume()
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        if let safeData = data {
            if let weatherModel = parseJSON(safeData) {
                delegate?.didUpdateWeather(weatherManager: self, weatherModel: weatherModel)
            }
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
        }
        catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    

}
