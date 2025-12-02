//
//  YelpAPIHandler.swift
//  Local-Grounds
//
//  Created by Carly Jazwin on 11/15/25.
//


//this file makes the api request
import Foundation

class YelpAPIService {
    //this is the base url for yelps business search
    private let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    //this func asks for yelps nearby cafes
    func searchCafes(
        latitude: Double,
        longitude: Double,
        term: String = "coffee",
        completion: @escaping (Result<[Cafe], Error>) -> Void
    )
    {   var components = URLComponents(string: baseURL)! //build the url with the params from the query
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "limit", value: "30")
        ]

        //this validates url
        guard let url = components.url else {
            completion(.failure(NSError(
                domain: "Yelp",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "URLS NOT VALID"]
            )))
            return
        }

        var request = URLRequest(url: url)  //GET METHOD for url req
        request.httpMethod = "GET"

        let apiKey = Secrets.yelpAPIKey //add the yelp api key from secrets
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            //make sure http response is valid
            guard let http = response as? HTTPURLResponse else {
                completion(.failure(NSError(
                    domain: "Yelp",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No HTTP"]
                )))
                return
            }

            //if yelp returned an error output
            guard (200..<300).contains(http.statusCode) else {
                let bodyString = String(data: data ?? Data(), encoding: .utf8) ?? "NO BODY"
                let error = NSError(
                    domain: "Yelp",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "PROBLEM W YELP: \(bodyString)"]
                )
                completion(.failure(error))
                return
            }

            //if no data was received from yelp
            guard let data = data else {
                completion(.failure(NSError(
                    domain: "Yelp",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "NO DATA"]
                )))
                return
            }
            
            //this is where we try to decode json
            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
                let cafes = decoded.businesses.map { $0.toCafe() }
                completion(.success(cafes))
            } catch { //catch in case the form doesnt match
                completion(.failure(error))
            }
        }.resume()
    }
}
