//
//  CafeDetailView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//VIEW FILE FOR THE DETAILS FOR EACH SELECTED CAFE

import SwiftUI
import MapKit
import Combine

struct CafeDetailView: View {
    let cafe: Cafe
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @EnvironmentObject var notesVM: NotesViewModel
    @State private var noteText: String = ""

    //MAIN VIEW BODY
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: cafe.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ) //set the coord region
                )) {
                    Marker(cafe.name, coordinate: cafe.coordinate)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(cafe.name)
                    .font(.title)
                    .bold()

                Text(cafe.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button {
                    openInMaps()
                } label: {
                    Label("Get Directions", systemImage: "map")
                        .font(.headline)
                }
                if let rating = cafe.rating {
                    Text("Rating: \(String(format: "%.1f", rating))")
                }
                if let price = cafe.price {
                    Text("Price: \(price)")
                }
                if let phone = cafe.phone, !phone.isEmpty {
                    Text("Phone: \(phone)")
                }
                if let urlString = cafe.yelpURL,
                   let url = URL(string: urlString) {
                    Link("View on Yelp", destination: url)
                        .font(.headline)
                }
                favoritesSection

                Divider()
                    .padding(.vertical, 8)

                notesSection
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let existing = notesVM.note(for: cafe) {
                noteText = existing.text
            }
        }
    }

//MARK: FUNCTION FOR THE SAVED CAFES
    private var favoritesSection: some View {
        let isFavorite = favoritesVM.isInFavorites(cafe)
        let isWishlist = favoritesVM.isInWishlist(cafe)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                Button {
                    if isFavorite {
                        favoritesVM.remove(cafe, from: .favorites)
                    } else {
                        favoritesVM.add(cafe, to: .favorites)
                    }
                } label: {
                    Label(
                        isFavorite ? "Favorited" : "Add to Favorites",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                }
                
                Button {
                    if isWishlist {
                        favoritesVM.remove(cafe, from: .wishlist)
                    } else {
                        favoritesVM.add(cafe, to: .wishlist)
                    }
                } label: {
                    Label(
                        isWishlist ? "On Wishlist" : "Add to Wishlist",
                        systemImage: isWishlist ? "star.fill" : "star"
                    )
                }
            }
        }
    }
    
//MARK: BIG FUNC FOR THE NOTES SECTION ON EACH CAFES DETAIL PAGE
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My note")
                .font(.headline)

            TextEditor(text: $noteText)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
            HStack {
                Button("Save Note") {
                    notesVM.saveNote(for: cafe, text: noteText)
                }
                .buttonStyle(.borderedProminent)

                if let existing = notesVM.note(for: cafe) {
                    let formatted = existing.updatedAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                    Text("Last updated \(formatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let existing = notesVM.note(for: cafe) {
                if let summary = existing.aiSummary, !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Summary")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text(summary)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(8)
                }
                HStack(spacing: 6) {
                    if let sentiment = existing.aiSentiment {
                        Text(sentiment.capitalized)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorForSentiment(sentiment).opacity(0.2))
                            .foregroundColor(colorForSentiment(sentiment))
                            .cornerRadius(999)
                    }
                    if let tags = existing.aiTags {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag.replacingOccurrences(of: "-", with: " ")) //text formatting
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.12))
                                .cornerRadius(999)
                        }
                    }
                    Spacer()
                }
                HStack {
                    if notesVM.isAnalyzingNoteId == existing.id {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Doing Analysis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Button {
                            Task {
                                await notesVM.analyzeNoteWithAI(existing)
                            }
                        } label: {
                            Text(existing.aiSummary == nil ? "Get Analysis" : "Re-analyze")
                                .font(.caption)
                        }
                    }
                    Spacer()
                }
            }
        }
    }

//MARK: HELPER FUNC TO COLOR CODE AI SENTIMENT ANALYSIS TAGS
    private func colorForSentiment(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "positive":
            return .green
        case "negative":
            return .red
        default:
            return .orange
        }
    }

//MARK: FUNC TO OPEN IM MAPS
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: cafe.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = cafe.name
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        mapItem.openInMaps(launchOptions: options)
    }
}
