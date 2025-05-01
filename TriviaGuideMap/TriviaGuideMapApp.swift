//
//  TriviaGuideMapApp.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//

import SwiftUI
import Firebase
import AVFoundation

@main
struct TriviaGuideMapApp: App {
    init() {
        FirebaseApp.configure()
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Sessionエラー: \(error)")
        }
    }
}
