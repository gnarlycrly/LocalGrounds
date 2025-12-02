//
//  CafeListView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//VIEW FILE FOR THE HOME LIST OF ALL CAFES
import SwiftUI

struct CafeListView: View {
    @EnvironmentObject var cafeListViewModel: CafeListViewModel //pass in the vms
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @State private var searchText = ""

    private var filteredCafes: [Cafe] { //trim text for filtered cafes
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return cafeListViewModel.cafes
        }

        return cafeListViewModel.cafes.filter { cafe in //return trimmed
            cafe.name.localizedCaseInsensitiveContains(trimmed) ||
            cafe.city.localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 12) {

            Image("localgroundslogo") //put logo at top above searchbar
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                .padding(.top, 8)

            SearchBar(text: $searchText)

            List {
                if filteredCafes.isEmpty { //if cant find cafes, display text for either change search or refresh
                    VStack(spacing: 8) {
                        Text("No cafes found")
                            .font(.headline)
                        Text("Try a different search or refresh the page.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                } else {
                    ForEach(filteredCafes) { cafe in
                        NavigationLink(destination: CafeDetailView(cafe: cafe)) {
                            CafeRowView(cafe: cafe)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .onAppear {
            cafeListViewModel.refresh()
        }
    }
}

//SEARCH BAR VIEW
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass") //mag glass for styling
                .foregroundColor(.gray)

            TextField("Search cafes", text: $text) //search textfield
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}


