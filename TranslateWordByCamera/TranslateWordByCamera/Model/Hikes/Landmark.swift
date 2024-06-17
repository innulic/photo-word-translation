//
//  LandMark.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 16/06/2024.
//

import Foundation
import CoreLocation
import SwiftUI

struct Landmark: Codable, Hashable, Identifiable{
    
    struct Coordinates: Hashable, Codable{
        var longitude: Double
        var latitude: Double
    }
    
    var name: String
    var category: String
    var city: String
    var state: String
    var id: Int
    var isFeatured: Bool
    var isFavorite: Bool
    var park: String
    var description: String
    var coordinates: Coordinates
    var coordinateLocaltion: CLLocationCoordinate2D{
        CLLocationCoordinate2D(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }
    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}
