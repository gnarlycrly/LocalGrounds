//
//  FavoritesViewModel.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//VIEW MODEL FOR FAVORITES
import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

//category for whether on favorites or wishlist
enum FavoritesCategory: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case wishlist = "Wishlist"

    var id: String { rawValue }
}

//MARK: FAVORITES VM
//this is main model for all the logic handling favorites and wishlist logic for saved cafes
class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Cafe] = [] //set vars to track when change
    @Published private(set) var wishlist: [Cafe] = []

    private let db = Firestore.firestore() //call database

    private var userId: String { //get user auth
        Auth.auth().currentUser?.uid ?? "unauthenticated-user"
    }

    private var favoritesCollection: CollectionReference { //favorites collection by user
        db.collection("users")
            .document(userId)
            .collection("favorites")
    }

    //same logic for wishlist
    private var wishlistCollection: CollectionReference {
        db.collection("users")
            .document(userId)
            .collection("wishlist")
    }

    // reload when user is different
    func reloadForCurrentUser() {
        guard Auth.auth().currentUser != nil else {
            favorites = []
            wishlist = []
            return
        }

        //found stack ex for this, but loading in each collection
        loadCollection(collection: favoritesCollection) { [weak self] cafes in
            self?.favorites = cafes
        }

        loadCollection(collection: wishlistCollection) { [weak self] cafes in
            self?.wishlist = cafes
        }
    }

    //MARK: ACTUAL LOADING FUNC
    private func loadCollection( //collection is loaded from firestore
        collection: CollectionReference,
        completion: @escaping ([Cafe]) -> Void
    ) {
        collection.getDocuments { snapshot, error in
                   guard let snapshot = snapshot, error == nil else {
                       completion([])
                       return
                   }
            let cafes: [Cafe] = snapshot.documents.compactMap { doc in
                let data = doc.data()
                guard
                    let id = data["id"] as? String,
                    let name = data["name"] as? String,
                    let address1 = data["address1"] as? String,
                    let city = data["city"] as? String,
                    let state = data["state"] as? String,
                    let zipCode = data["zipCode"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else {
                    return nil
                }
                return Cafe( //return cafe loaded from list
                    id: id,
                    name: name,
                    address1: address1,
                    city: city,
                    state: state,
                    zipCode: zipCode,
                    latitude: latitude,
                    longitude: longitude,
                    rating: data["rating"] as? Double,
                    price: data["price"] as? String,
                    phone: data["phone"] as? String,
                    imageURL: data["imageURL"] as? String,
                    yelpURL: data["yelpURL"] as? String
                )
            }
            completion(cafes)
        }
    }

    // return cafes for selected category (either favs or wishlist)
    func cafes(for category: FavoritesCategory) -> [Cafe] {
        switch category {
        case .favorites:
            return favorites
        case .wishlist:
            return wishlist
        }
    }

    // check if cafe already in fav list
    func isInFavorites(_ cafe: Cafe) -> Bool {
        favorites.contains { favorite in
            favorite.id == cafe.id
        }
    }

    // same check for wishlist
    func isInWishlist(_ cafe: Cafe) -> Bool {
        wishlist.contains { wishCafe in
            wishCafe.id == cafe.id
        }
    }

    //add cafe to favs/wishlist if not already there
    //save to collection for db
    func add(_ cafe: Cafe, to category: FavoritesCategory) {
        switch category {
        case .favorites:
            //if not in favs, add
            if !isInFavorites(cafe) {
                favorites.append(cafe)
                saveCafe(cafe, in: favoritesCollection)
            }

        case .wishlist:
            //if not in wihslist, add
            if !isInWishlist(cafe) {
                wishlist.append(cafe)
                saveCafe(cafe, in: wishlistCollection)
            }
        }
    }

    //remove cafe and delete from db
    func remove(_ cafe: Cafe, from category: FavoritesCategory) {
        switch category {
        case .favorites:
            favorites.removeAll { favorite in
                favorite.id == cafe.id
            }
            favoritesCollection.document(cafe.id).delete()

        case .wishlist:
            wishlist.removeAll { wishCafe in
                wishCafe.id == cafe.id
            }
            wishlistCollection.document(cafe.id).delete()
        }
    }

    //remove from both lists and from db
    func removeFromAll(_ cafe: Cafe) {
        favorites.removeAll { favorite in
            favorite.id == cafe.id
        }
        wishlist.removeAll { wishCafe in
            wishCafe.id == cafe.id
        }

        favoritesCollection.document(cafe.id).delete()
        wishlistCollection.document(cafe.id).delete()
    }

    //helper to save to db
    private func saveCafe(_ cafe: Cafe, in collection: CollectionReference) {
        let data: [String: Any] = [
            "id": cafe.id,
            "name": cafe.name,
            "address1": cafe.address1,
            "city": cafe.city,
            "state": cafe.state,
            "zipCode": cafe.zipCode,
            "latitude": cafe.latitude,
            "longitude": cafe.longitude,
            "rating": cafe.rating as Any,
            "price": cafe.price as Any,
            "phone": cafe.phone as Any,
            "imageURL": cafe.imageURL as Any,
            "yelpURL": cafe.yelpURL as Any
        ]

        collection.document(cafe.id).setData(data) { error in
            if let error = error {
                print("ERROR SAVING", error)
            }
        }
    }
}
