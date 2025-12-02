//
//  CafeRecord.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//ACTUAL CAFE MODEL
//RECORD STRUCT FOR EACH CAFE

import Foundation
import CoreLocation

//this is the MAIN model for each individual cafe
//vars for yelp url so we can associate each with an entry from yelp
struct Cafe: Identifiable, Codable, Equatable {
    //all attributes that define each cafe
    let id: String      //unique id
    let name: String
    let address1: String
    let city: String
    let state: String
    let zipCode: String
    let latitude: Double
    let longitude: Double
    let rating: Double? //all these are optional from yelp just in case
    let price: String?
    let phone: String?
    let imageURL: String?
    let yelpURL: String?

    //make this as coords w the lat and lon so I can use with map
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //format the full address with the attributes to show
    var fullAddress: String {
        "\(address1), \(city), \(state) \(zipCode)"
    }
}

//
extension Cafe { //extension off of model
    //func to convert this into firestore
    //have to associate with favorites category (either saved or wishlist)
    func toFirestoreData(category: FavoritesCategory) -> [String: Any] {
        //cafe data holding all info for firestore dict, only including the non nil optional vals
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "address1": address1,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "latitude": latitude,
            "longitude": longitude,
            "category": category.rawValue
        ]
        
        if let rating = rating {
            data["rating"] = rating
        }
        if let price = price {
            data["price"] = price
        }
        if let phone = phone {
            data["phone"] = phone
        }
        if let imageURL = imageURL {
            data["imageURL"] = imageURL
        }
        if let yelpURL = yelpURL {
            data["yelpURL"] = yelpURL
        }
        
        return data
    }
}
