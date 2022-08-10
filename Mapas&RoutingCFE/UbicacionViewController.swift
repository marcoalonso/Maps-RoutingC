//
//  ViewController.swift
//  Mapas&RoutingCFE
//
//  Created by marco rodriguez on 10/08/22.
//

import UIKit
import MapKit
import CoreLocation

class UbicacionViewController: UIViewController {
    
    @IBOutlet weak var Mapa: MKMapView!
    
    var manager = CLLocationManager()
    
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
    }
    
    @IBAction func ubicacionBtn(_ sender: UIBarButtonItem) {
        manager.requestLocation() //vuelve a pedir la ubicacion del usuario
        
        let ubicacionMapa = CLLocationCoordinate2D(latitude: latitud ?? 19.39484, longitude: longitud ?? -101.1874)
        //nivel del zoom
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let regionMapa = MKCoordinateRegion(center: ubicacionMapa, span: spanMapa)
        
        //Agregar la region al mapa y mostrar la ubicacion del usuario
        Mapa.setRegion(regionMapa, animated: true)
        Mapa.showsUserLocation = true
    }
    
    @IBAction func CoordenadasBtn(_ sender: UIBarButtonItem) {
        //Mostrar una alerta con las coordenadas del usuario
        let alerta = UIAlertController(title: "Ubicacion", message: "Tu coordenadas son: Lat: \(latitud ?? 0) Lon: \(longitud ?? 0)", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Ok", style: .default) { (_) in
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)

    }
    
}

extension UbicacionViewController: CLLocationManagerDelegate {
    
    //que hacer cuando se obtuvo la ubicacio didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Se obtuvo la ubicacion")
        if let ubicacion = locations.first {
            latitud = ubicacion.coordinate.latitude
            longitud = ubicacion.coordinate.longitude
            //Dejar de obtener la ubicacion
           // manager.stopUpdatingLocation()
        }
    }
    
    //que hacer cuando NO se obtuvo la ubicacio didFailWithError
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicacion")
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            //Acceder a la ubicacion
            manager.requestLocation()
        case .authorized:
            print("authorized")
        @unknown default:
            fatalError("Error desconocido :/")
        }
    }
}

