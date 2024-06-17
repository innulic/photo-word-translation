//
//  GoogleTranslateView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 26/04/2024.
//

import SwiftUI
import Alamofire

var apiKey: String = "AIzaSyBGEAcdHI-Kw0ltEUdcmroF7pFboOFYvcg"
var translateServiceBaseUrl = "https://translation.googleapis.com/language/translate/v2"

struct GoogleTranslateView: View {
    @State private var translation: String = ""
    
    var body: some View {
        VStack{
            Text(translation)
            Button("Translate"){
                translate(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
        .padding()
    }
    
    func translate(_ text: String){
        let parameters: [String: Any] = [
            "q": text,
            "target": "ru",
            "key": apiKey
        ]
        AF.request(translateServiceBaseUrl,
                   method: .post,
                   parameters: parameters)
            .validate()
            .responseDecodable(of: TranslationResponse.self) {response in
                switch response.result {
                    case .success(let value):
                        translation = value.data.translations.first?.translatedText ?? ""
                    case .failure(let error):
                        print("Failed to translate text: \(error)")
                }
            }
    }
}

struct TranslationResponse: Decodable {
    let data: TranslationData
}

struct TranslationData: Decodable {
    let translations: [Translation]
}

struct Translation: Decodable {
    let translatedText: String
}

#Preview {
    GoogleTranslateView()
}
