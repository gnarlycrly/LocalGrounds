//
//  StartupScreensView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/15/25.
//

//first startup screen with swipeable func based off my figma ui mockups
import SwiftUI

struct StartupScreensView: View {
    @EnvironmentObject var authVM: LoginViewModel //bring in login vm to verify users logged in
    @State private var pageIndex: Int = 0 //keep track of which page users on of swipe, login or main

    var body: some View {
        ZStack { //ztack the purple bg for theme
            Color("PurpleBackground")
                .ignoresSafeArea()

            TabView(selection: $pageIndex) {
                FirstPageView() //first view w logo and pic
                    .tag(0)

                LoginView() //or login view
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always)) //tab view for the dots like my ui
        }
    }
}

