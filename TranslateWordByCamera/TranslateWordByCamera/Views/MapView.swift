//
//  MapView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 26/04/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        Map(initialPosition: .region(region))
    }
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.3455496943173, longitude: -6.239012185643174),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta:0.2)
        )
    }
}

#Preview {
    MapView()
}
