//
//  ParkService.swift
//  ParkBirdie
//
//  Created by Chiwon Song on 10/2/23.
//

import Combine
import CoreLocation
import Foundation
import Observation

@Observable
class ParkService: NSObject {
    private let locationManager = CLLocationManager()
    private var allParks: [Park] = []

    var park: Park?

    override init() {
        super.init()

        if let url = Bundle.main.url(forResource: "public_park", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let parks = try? JSONDecoder().decode([Park].self, from: data) {
            allParks = parks
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func distance(from pos1: CLLocationCoordinate2D, to pos2: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: pos1.latitude, longitude: pos1.longitude)
        let loc2 = CLLocation(latitude: pos2.latitude, longitude: pos2.longitude)
        return loc2.distance(from: loc1)
    }

    private func isIn(park: Park, location: CLLocationCoordinate2D) -> Bool {
        let AREA_LIMIT: Double = 10 * 1000 // 10km
        let distance = distance(from: location,
                                to: CLLocationCoordinate2D(latitude: park.latitude,
                                                           longitude: park.longitude))
        return distance <= AREA_LIMIT
    }

    private func findParkBy(location: CLLocationCoordinate2D) -> Park? {
        return allParks.first { isIn(park: $0, location: location) }
    }
}

// MARK: - CLLocationManagerDelegate

extension ParkService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last,
           let park = findParkBy(location: location.coordinate) {
            self.park = park
        } else {
            self.park = park
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
