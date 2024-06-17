//
//  HikeRow.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 16/06/2024.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        )
    }
}

struct HikeRow: View {
    var hike: Hike
    @State var showDetails = true
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
                withAnimation{
                    showDetails.toggle()
                }
            }label: {
                Label("Graph", systemImage: "chevron.right.circle")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
                    .rotationEffect(.degrees(showDetails ? 90 : 0))
                    //.scaleEffect(showDetails ? 1.5 : 1)
                    .padding()
                    //.animation(.spring, value: showDetails)
            }
        }
        
        if(showDetails){
            HikeDetail(hike: hike)
                .transition(.slide)
        }
    }
}

#Preview {
    let hikes = ModelData().hikes
    return Group{
        HikeRow(hike: hikes[0])
    }
}
