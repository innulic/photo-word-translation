//
//  ContentView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 26/04/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LandmarkList()
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
