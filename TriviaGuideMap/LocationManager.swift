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
    private let geocoder = CLGeocoder()

    @Published var location: CLLocationCoordinate2D?
    @Published var lastUpdated: Date = Date()
    @Published var placeName: String = ""

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
        reverseGeocode(location: latest)
    }

    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("逆ジオコード失敗: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    if let name = placemark.name {
                        self?.placeName = name
                    } else if let thoroughfare = placemark.thoroughfare {
                        self?.placeName = thoroughfare
                    } else if let subLocality = placemark.subLocality {
                        self?.placeName = subLocality
                    } else if let locality = placemark.locality {
                        self?.placeName = locality
                    } else {
                        self?.placeName = "場所不明"
                    }
                    print(self?.placeName)
                }
            } else {
                DispatchQueue.main.async {
                    self?.placeName = "場所不明"
                }
            }
        }
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
}

//import Foundation
//import CoreLocation
//import FirebaseFirestore
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private let manager = CLLocationManager()
//
//    @Published var location: CLLocationCoordinate2D?
//    @Published var lastUpdated: Date = Date()
//
//    override init() {
//        super.init()
//        manager.delegate = self
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
//        manager.requestAlwaysAuthorization()
//        manager.allowsBackgroundLocationUpdates = true
//        manager.pausesLocationUpdatesAutomatically = false
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let latest = locations.last else { return }
//        location = latest.coordinate
//        lastUpdated = Date()
//    }
//
//    func sendLocationToFirestore(latitude: Double, longitude: Double) {
//        let db = Firestore.firestore()
//
//        db.collection("locations").addDocument(data: [
//            "latitude": latitude,
//            "longitude": longitude,
//            "timestamp": Timestamp(date: Date())
//        ]) { error in
//            if let error = error {
//                print("Firestore書き込みエラー: \(error.localizedDescription)")
//            } else {
//                print("Firestore書き込み成功！")
//            }
//        }
//    }
//
//    func fetchFunFact(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
//        guard let url = URL(string: "https://us-central1-triviaguidemap.cloudfunctions.net/getFunFact") else {
//            completion("URLエラー")
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let body: [String: Any] = [
//            "latitude": latitude,
//            "longitude": longitude
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                  let funfact = json["funfact"] as? String else {
//                completion("レスポンス取得エラー")
//                return
//            }
//
//            completion(funfact)
//        }.resume()
//    }
//}
