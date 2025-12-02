//
//  FavoriteView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//VIEW FILE FOR SAVED
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesVM: FavoritesViewModel //pass in vms and category
    @State private var selectedCategory: FavoritesCategory = .favorites

    var body: some View {
        VStack {
            Image("localgroundslogo") //always want to put the logo at the top
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .padding(.top, 8)
            
            Picker("List", selection: $selectedCategory) { 
                ForEach(FavoritesCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            let cafes = favoritesVM.cafes(for: selectedCategory)

            if cafes.isEmpty {
                VStack(spacing: 8) {
                    Text(selectedCategory == .favorites ? "No favorites yet" : "No cafes in your wishlist yet")
                        .font(.headline)
                    Text("Tap the \(selectedCategory == .favorites ? "heart" : "star") on a cafe to add it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
            } else {
                List {
                    ForEach(cafes) { cafe in
                        NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                            CafeRowView(cafe: cafe)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let cafe = cafes[index]
                            favoritesVM.remove(cafe, from: selectedCategory)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
