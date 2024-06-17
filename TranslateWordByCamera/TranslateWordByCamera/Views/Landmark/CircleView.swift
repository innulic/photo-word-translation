//
//  CircleView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 26/04/2024.
//

import SwiftUI

struct CircleView: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .overlay{
                Circle().stroke(.gray, lineWidth: 4)
            }
            .shadow(radius: 10)
    }
}

#Preview {
    CircleView(image: Image("turtlerock"))
}
