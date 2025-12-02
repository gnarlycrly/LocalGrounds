//
//  MapView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//map view for map tab with the annotation markers, themed w coffee cups/hearts

import SwiftUI
import MapKit
import Combine

struct CafeMapView: View {
    @EnvironmentObject var cafeListVM: CafeListViewModel
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var region: MKCoordinateRegion?

    var body: some View {
        ZStack {
            if let region = region { //if alrd havr region, show it
                Map(initialPosition: .region(region)) {
                    ForEach(cafeListVM.cafes) { cafe in //place pin for any cafe
                        let coord = cafe.coordinate

                        Annotation(cafe.name, coordinate: coord) { //actual pin
                            NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .frame(width: 34, height: 34)
                                            .foregroundStyle(.white)
                                        Image(
                                            systemName: favoritesVM.isInFavorites(cafe)
                                            ? "heart.fill" //if its alrd saved put heart
                                            : "cup.and.saucer.fill" //fill with cup if not in favorites
                                        )
                                        .imageScale(.medium)
                                        .foregroundColor(.brown)
                                    }
                                    Text(cafe.name)
                                        .font(.caption2)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .frame(maxWidth: 80)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            } else {
                ProgressView("Loading Map…") //text for loading
            }
        }
        //when screen appears set initial region
        .onAppear {
            if region == nil {
                if let vmRegion = cafeListVM.mapRegion {
                    region = vmRegion
                } else if let coord = cafeListVM.userCoordinate {
                    region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                }
            }
        }
        //when vm updates mapregion
        .onReceive(cafeListVM.$mapRegion.compactMap { $0 }) { newRegion in
            if region == nil {
                region = newRegion
            }
        }
    }
}
