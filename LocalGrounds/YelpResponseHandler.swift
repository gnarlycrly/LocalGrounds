//
//  YelpResponseHandler.swift
//  Local-Grounds
//
//  Created by Carly Jazwin on 11/15/25.
//

//this file decodes the yelp json into my swift structs
import Foundation

struct YelpSearchResponse: Decodable { //matches yelp json
    let businesses: [YelpBusiness] //array of each yelp bus
}

//this struct represents ONE yelp business w all the json attributes
struct YelpBusiness: Decodable {
    let id: String
    let name: String
    let rating: Double?
    let price: String?
    let phone: String?
    let url: String
    let coordinates: YelpCoordinates
    let location: YelpLocation
    let image_url: String?

    //matches yelp coord json
    struct YelpCoordinates: Decodable {
        let latitude: Double
        let longitude: Double
    }

    //matches yelp loc json
    struct YelpLocation: Decodable {
        let address1: String?
        let city: String?
        let state: String?
        let zip_code: String?
    }

    //converts yelp bus to my cafe record struct
    func toCafe() -> Cafe {
        Cafe(
            id: id,
            name: name,
            address1: location.address1 ?? "ADDRESS UNKNOWN", //fallback just in case
            city: location.city ?? "",
            state: location.state ?? "",
            zipCode: location.zip_code ?? "",
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            rating: rating,
            price: price,
            phone: phone,
            imageURL: image_url,
            yelpURL: url
        )
    }
}
