//
//  ContentView.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//
//
//  ContentView.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    private let speechSynthesizer = AVSpeechSynthesizer()

    @State private var lastSpokenTime: Date = Date(timeIntervalSince1970: 0)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapView()
                .edgesIgnoringSafeArea(.all)

            Button(action: {
                manualSpeak()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding()
            }
        }
        .onAppear {
            configureAudioSession()
        }
        .onChange(of: locationManager.lastUpdated) { _ in
            autoSpeakIfNeeded()
        }
    }

    func manualSpeak() {
        let placeName = locationManager.placeName
        if placeName.isEmpty {
            print("placeNameが取得できませんでした。")
            return
        }
        fetchAndSpeak(placeName: placeName)
    }

    func autoSpeakIfNeeded() {
        let now = Date()
//        if now.timeIntervalSince(lastSpokenTime) > 60, let placeName = locationManager.placeName {
//            fetchAndSpeak(placeName: placeName)
//            lastSpokenTime = now
//        }
    }

    func fetchAndSpeak(placeName: String) {
        fetchFunFact(placeName: placeName) { fact in
            DispatchQueue.main.async {
                let utterance = AVSpeechUtterance(string: fact ?? "情報が取得できませんでした。")
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                utterance.rate = 0.5
                speechSynthesizer.speak(utterance)
            }
        }
    }

    func fetchFunFact(placeName: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-triviaguidemap.cloudfunctions.net/getFunFact") else {
            completion("URLエラー")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "placeName": placeName
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let funfact = json["funfact"] as? String else {
                completion("レスポンス取得エラー")
                return
            }
            completion(funfact)
        }.resume()
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Sessionエラー: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
