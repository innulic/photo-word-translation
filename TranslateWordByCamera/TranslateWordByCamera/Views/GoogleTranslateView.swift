//
//  GoogleTranslateView.swift
//  TranslateWordByCamera
//
//  Created by Inna Ankudinova on 26/04/2024.
//

import SwiftUI

struct GoogleTranslateView: View {
    @State private var translation: String = ""
    @State private var translationController: TranslationController = TranslationController()
    
    var body: some View {
        VStack{
            Text(translation)
            Button("Translate"){
                translationController.translate(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/){ result in
                    switch result {
                    case .success(let translatedText):
                        print("Translated text: \(translatedText)")
                        translation = translatedText
                    case .failure(let error):
                        print("Failed to translate text: \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding()
    }
}



#Preview {
    GoogleTranslateView()
}
