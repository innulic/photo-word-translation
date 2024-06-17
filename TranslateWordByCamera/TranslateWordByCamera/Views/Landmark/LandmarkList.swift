//
//  LandmarkList.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 16/06/2024.
//

import SwiftUI

struct LandmarkList: View {
    @Environment(ModelData.self) var modelData
    @State private var showFavotiteOnly = false
    
    var filterLandMarks: [Landmark]{
        modelData.landmarks.filter{ landmark in
            (!showFavotiteOnly || landmark.isFavorite)
        }
    }
    
    var body: some View {
        NavigationSplitView{
            List{
                Toggle(isOn: $showFavotiteOnly) {
                    Text("Show Favorite Only")
                }
                ForEach(filterLandMarks){ landmark in
                    NavigationLink{
                        LandmarkDetailView(landmark: landmark)
                    } label:{
                        LandmarkRow(landmark: landmark)
                    }
                    
                }
            }
            .animation(.default, value: filterLandMarks)
            .navigationTitle("Landmarks")
        } detail: {
            Text("Select a landmark")
        }
    }
}

#Preview {
    LandmarkList()
        .environment(ModelData())
}
