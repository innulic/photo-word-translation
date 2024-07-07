//
//  TRanslationController.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 07/07/2024.
//

import Foundation
import Alamofire

var apiKey: String = "AIzaSyAda2L4HWLPIonW5zrBiMnzIzxfI507VTI"

class TranslationController
{
    func translate(_ text: String, completion: @escaping (Result<String, Error>) -> Void){
        let parameters: [String: Any] = [
            "q": text,
            "target": "ru",
            "key": apiKey
        ]
        AF.request("https://translation.googleapis.com/language/translate/v2",
                   method: .post,
                   parameters: parameters)
            .validate()
            .responseDecodable(of: TranslationResponse.self) {response in
                switch response.result {
                    case .success(let value):
                        if let translatedText = value.data.translations.first?.translatedText {
                            completion(.success(translatedText))
                        } else {
                            // Handle the case where translation is not available
                            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Translation not available"])))
                        }
                    case .failure(let error):
                        print("Failed to translate text: \(error)")
                        completion(.failure(error))
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
