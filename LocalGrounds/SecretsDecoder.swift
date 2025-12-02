//
//  SecretsDecoder.swift
//  Local-Grounds
//
//  Created by Carly Jazwin on 11/05/25.
//

//found youtube tut for the creation of this to hide api key
import Foundation
enum Secrets{
    static var yelpAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["YELP_API_KEY"] as? String else {
            fatalError("Missing Yelp API Key")
        }
        return key
    }
}
