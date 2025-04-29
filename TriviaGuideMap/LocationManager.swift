//
//  LocationManager.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//

import Foundation
import CoreLocation
import FirebaseFirestore

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var lastUpdated: Date = Date()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        location = latest.coordinate
        lastUpdated = Date()
    }

    func sendLocationToFirestore(latitude: Double, longitude: Double) {
        let db = Firestore.firestore()
        
        db.collection("locations").addDocument(data: [
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("Firestore書き込みエラー: \(error.localizedDescription)")
            } else {
                print("Firestore書き込み成功！")
            }
        }
    }
    
    func fetchFunFact(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-triviaguidemap.cloudfunctions.net/getFunFact") else {
            completion("URLエラー")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude
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
}
