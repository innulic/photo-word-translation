//
//  Configuration.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 04/08/2024.
//

import Foundation

class Configuration{
    static let shared = Configuration()
    var googleApiKey: String = ""
    
    private init(){
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path){
            var value = config["GoogleAPIKey"] as? String
            googleApiKey = value ?? ""
        }
    }
}
