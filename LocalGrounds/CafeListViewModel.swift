//
//  CafeListViewModel.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//VIEW MODEL FOR CAFE LISTS

import Foundation
import CoreLocation
import MapKit
import Combine

//this is main view model that keeps track of shown cafes and deals with location and yelp to load them in

class CafeListViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    //all cafes currently loaded in from yelp
    @Published var cafes: [Cafe] = []
    @Published var searchText: String = "" //searchbar text
    @Published var isLoading: Bool = false //currently loading in yelp data bool
    @Published var errorMessage: String? //optional err
    @Published var userCoordinate: CLLocationCoordinate2D? //last user coords
    @Published var mapRegion: MKCoordinateRegion?

    private let locationManager = CLLocationManager()
    private let yelpService = YelpAPIService() //yelp service wraps api calls for yelp

    override init() {
        super.init()
        locationManager.delegate = self //set self as loc manager del
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //desired accuracy for loc, dont need super super precise. so this is good
    }

    var filteredCafes: [Cafe] {
        guard !searchText.isEmpty else { return cafes }
        let text = searchText.lowercased()
        return cafes.filter {
            $0.name.lowercased().contains(text) ||
            $0.fullAddress.lowercased().contains(text)
        }
    }

    func refresh() {
        print("CafeListViewModel.refresh() – userCoordinate:", String(describing: userCoordinate))
        if let coord = userCoordinate {
            //load cafes near the users coord location
            loadCafes(near: coord)
        } else {
           //if dont have loc, i just set default to tempe
            let defaultTempe = CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.94)
            print("No location! Showing cafes in tempe until location services are enables")
            loadCafes(near: defaultTempe)
            //if requested loc is approved, use that instead
            requestLocation()
        }
    }

//MARK: FUNC TO REQUEST LOC
    func requestLocation() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access hasn't been enabled! Go to settings and make sure its on"
        @unknown default:
            break
        }
    }
//MARK: FUNC TO LOAD CAFES
    private func loadCafes(near coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        yelpService.searchCafes(latitude: coordinate.latitude, longitude: coordinate.longitude) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let cafes):
                    self.cafes = cafes
                    self.mapRegion = MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    //LOC MANAGER FUNC
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        let coord = loc.coordinate
        DispatchQueue.main.async {
            self.userCoordinate = coord
        }
        loadCafes(near: coord)
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
                return
            }
        
        DispatchQueue.main.async {
            self.errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
}
