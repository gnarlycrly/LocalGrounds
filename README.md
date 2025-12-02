
# ☕ LocalGrounds

Discover coffee shops. Save favorites. Keep personal notes. Explore your city.

## Screenshots

<img width="308"  alt="Screenshot 2025-12-01 at 6 58 11 PM" src="https://github.com/user-attachments/assets/e9f233aa-6a5e-49e5-842d-d1db16f75c83" />

<img width="300" alt="Screenshot 2025-12-01 at 6 58 42 PM" src="https://github.com/user-attachments/assets/53baf9ab-b80f-4c89-a732-177e8ad6c471" />

<img width="308"  alt="Screenshot 2025-12-01 at 6 47 34 PM" src="https://github.com/user-attachments/assets/b4a24c0c-78a4-4c03-bb81-a3d3b42643b4" />

<img width="308"  alt="Screenshot 2025-12-01 at 6 54 32 PM" src="https://github.com/user-attachments/assets/0299a85b-8758-4342-926a-e49aaac6116e" />


## 🚀 Overview

LocalGrounds is a SwiftUI-based iOS app designed to help users discover new coffee shops, save favorites, and keep personal notes about each café. It provides a clean and intuitive experience for exploring local coffee culture — perfect for users who like to track their favorite spots, rate drinks, and remember unique experiences.

The app integrates:

- Yelp Fusion API for real coffee shop data (ratings, photos, pricing, hours, categories)
- OpenAI API for AI-generated café summaries & personalized suggestions
- Firebase Firestore for notes + favorites
- SwiftUI + MVVM for a clean, maintainable architecture
- CoreLocation for live location-based search

LocalGrounds is designed to be fast, beautiful, and personal — letting users explore coffee shops and build their own café journal.
# ✨ Features

## 🔎 Coffee Shop Discovery (Yelp API)

- Fetches nearby coffee shops using Yelp Fusion API

- Displays:

  -  Name

  - Rating

  - Location

  - Price level

  -  Categories

  - Photos

  - Distance from user`

- Refreshes automatically based on user location

## 🤖 AI-Generated Café Summaries (OpenAI API)

- Auto-summaries for each café 
- Sentiment analysis for easy filtering

- Smooth async generation integrated with SwiftUI

## ⭐ Favorites System

- Save/unsave favorite cafés

- Synced to Firestore per user

- Appears instantly in the Favorites tab

## 📝 Café Notes

- Add personal notes for any coffee shop

- Notes auto-sync via Firestore

- Sorted by most recently updated

## 🌎 Location-Based Search

- Uses CoreLocation for GPS coordinates

- Automatically reloads café list when location changes

## 🎨 Modern SwiftUI UI

- MVVM architecture

- Custom components for cards, buttons, and modals

- Smooth tab navigation

# 🛠️ Tech Stack
## Frontend (iOS)

- SwiftUI
- MVVM architecture
- Combine
- CoreLocation
- Async/await networking
- Swift Package Manager (SPM)

## APIs

- Yelp Fusion REST API
  - Used for café discovery
  - Pulls metadata, ratings, pricing, and images

- OpenAI API
  - Text generation for café summaries & sentiment analysis

## Backend

- Firebase Firestore for persistence
- Firebase Authentication for lightweight user identity
