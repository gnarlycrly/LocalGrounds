//
//  FirstPageView.swift
//  LocalGrounds
//
//  Created by Carly Jazwin on 11/05/25.
//

//this is the first page view of the slider, has the logo and picture
import SwiftUI

struct FirstPageView: View {
    var body: some View {
        ZStack { //zstack for theme purple bg
            Color("PurpleBackground")
                .ignoresSafeArea()
            VStack {
                Spacer()

                Image("coffee") //coffee pic
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)

                Image("localgroundslogo") //logo image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)

                Spacer()
            }
        }
    }
}

