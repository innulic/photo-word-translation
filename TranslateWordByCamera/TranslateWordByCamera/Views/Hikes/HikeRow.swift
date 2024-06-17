//
//  HikeRow.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 16/06/2024.
//

import SwiftUI

struct HikeRow: View {
    var hike: Hike
    @State var showDetails = false
    var body: some View {
            HStack{
                HikeGraph(hike: hike, path: \.elevation)
                    .frame(width: 50, height: 30)
                
                VStack(alignment: .leading){
                    Text(hike.name)
                        .font(.headline)
                    Text(hike.distanceText)
                }
                
                Spacer()
                
                Button{
                    showDetails.toggle()
                }label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(.degrees(showDetails ? 90 : 0))
                        .padding()
                }
                
                if(showDetails){
                    HikeDetail(hike: hike)
                }
        }
    }
}

#Preview {
    let hikes = ModelData().hikes
    return Group{
        HikeRow(hike: hikes[0])
    }
}
