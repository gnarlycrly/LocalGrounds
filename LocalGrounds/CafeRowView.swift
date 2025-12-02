//
//  CafeRowView.swift
//  LocalGrounds
//
//  This shows ONE café inside a list.
//

import SwiftUI

struct CafeRowView: View {

    let cafe: Cafe
    @EnvironmentObject var favoritesVM: FavoritesViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            cafeImage
            VStack(alignment: .leading, spacing: 4) {

                Text(cafe.name)
                    .font(.headline)

                Text(cafe.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 8) {
                    if let rating = cafe.rating {
                        Text("Rating \(String(format: "%.1f", rating))/5")
                            .font(.caption)
                    }

                    if let price = cafe.price {
                        Text(price)
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }

            Spacer()
            VStack(spacing: 8) {
                favoriteButton
                wishlistButton
            }
        }
        .padding(.vertical, 4)
    }

    private var cafeImage: some View {
        Group {
            if let imageURLString = cafe.imageURL,
               let url = URL(string: imageURLString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {
                    Color.gray.opacity(0.2)
                }

            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var favoriteButton: some View {
        let isFavorite = favoritesVM.isInFavorites(cafe)

        return Button {

            if isFavorite {
                favoritesVM.remove(cafe, from: .favorites)
            } else {
                favoritesVM.add(cafe, to: .favorites)
            }

        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? .red : .gray)
                .imageScale(.large)
        }
        .buttonStyle(.plain)
    }

    private var wishlistButton: some View {
        let isWishlist = favoritesVM.isInWishlist(cafe)

        return Button {

            if isWishlist {
                favoritesVM.remove(cafe, from: .wishlist)
            } else {
                favoritesVM.add(cafe, to: .wishlist)
            }

        } label: {
            Image(systemName: isWishlist ? "star.fill" : "star")
                .foregroundColor(isWishlist ? .yellow : .gray)
                .imageScale(.large)
        }
        .buttonStyle(.plain)
    }
}


