//
//  HikeView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 16/06/2024.
//

import SwiftUI

struct HikeView: View {
    @Environment(ModelData.self) var modelData
    var body: some View {
        List{
            ForEach(modelData.hikes){ hike in
                HikeRow(hike: hike)
            }
        }
    }
}

#Preview {
    HikeView()
        .environment(ModelData())
}
