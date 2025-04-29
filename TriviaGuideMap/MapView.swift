//
//  MapView.swift
//  TriviaGuideMap
//
//  Created by KAMAKURAKAZUHIRO on 2025/04/29.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125), // 東京駅スタート
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onReceive(locationManager.$location) { location in
                if let location = location {
                    region.center = location
                    // ここでもprintしていい
                    print("Map更新: 緯度\(location.latitude), 経度\(location.longitude)")
                }
            }
            .edgesIgnoringSafeArea(.all)
    }
}
