//
//  Location.swift
//  Hiker
//
//  Created by Niladri Bora on 9/29/24.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
  static let sanFrancisco: Self = .init(
    latitude: 37.733795,
    longitude: -122.446747
  )
  
  var mapRect:MKMapRect {
    return MKMapRect(
      origin: MKMapPoint(.sanFrancisco),
      size: MKMapSize(width: 1, height: 1))
  }
}

/**
 attribution: https://www.andyibanez.com/posts/using-corelocation-with-swiftui/
 */
@Observable
class LocationModel: NSObject, CLLocationManagerDelegate {
  var authorizationStatus: CLAuthorizationStatus
  var lastSeenLocation: CLLocation?
  var currentPlacemark: CLPlacemark?
  
  private let locationManager: CLLocationManager
  
  override init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastSeenLocation = locations.first
    fetchCountryAndCity(for: locations.first)
  }
  
  func fetchCountryAndCity(for location: CLLocation?) {
    guard let location = location else { return }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      self.currentPlacemark = placemarks?.first
    }
  }
  
}
