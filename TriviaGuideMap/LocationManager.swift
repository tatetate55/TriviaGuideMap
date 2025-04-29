//
//  LocationManager.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        location = newLocation.coordinate
        print("現在地取得: 緯度\(newLocation.coordinate.latitude), 経度\(newLocation.coordinate.longitude)")
    }
}
