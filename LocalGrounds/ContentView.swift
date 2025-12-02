//
//  ContentView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 10/25/25.
//

//CONTENTVIEW HOUSES VIEWS
import SwiftUI

struct ContentView: View { //pull in all the vms for the logic for login, favs, notes, and cafes
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject private var cafeListViewModel = CafeListViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var notesViewModel = NotesViewModel()

    var body: some View {
        rootView
            .onChange(of: loginVM.user) { _ in
                notesViewModel.loadNotes()
                favoritesViewModel.reloadForCurrentUser()
                cafeListViewModel.requestLocation()
            }
            .environmentObject(cafeListViewModel)
            .environmentObject(favoritesViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(loginVM)
    }

    @ViewBuilder
    private var rootView: some View {
        if loginVM.user == nil {
            StartupScreensView()
        } else {
            MainTabView()
        }
    }
}

struct MainTabView: View { //house the bottom tabs for each page
    var body: some View {
        TabView {
            NavigationStack {
                CafeListView()
            }
            .tabItem {
                Label("Nearby", systemImage: "cup.and.saucer")
            }

            NavigationStack {
                CafeMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Saved", systemImage: "heart")
            }

            NavigationStack {
                NotesListView()
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}
