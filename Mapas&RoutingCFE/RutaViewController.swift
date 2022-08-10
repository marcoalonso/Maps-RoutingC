//
//  RutaViewController.swift
//  Mapas&RoutingCFE
//
//  Created by marco rodriguez on 10/08/22.
//

import UIKit
import MapKit
import CoreLocation

class RutaViewController: UIViewController {
    
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var direccionBuscarSB: UISearchBar!
    
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        direccionBuscarSB.delegate = self
        manager.delegate = self
        mapa.delegate = self
        
        //Permisos y ubicacion del usuario
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        mapa.showsUserLocation = true
    }

}


extension RutaViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .purple
        return renderizado
    }
    
    // MARK: - Custom  Anotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        var anotationView = mapa.dequeueReusableAnnotationView(withIdentifier: "custom")

        if anotationView == nil {
            anotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            anotationView?.annotation = annotation
        }
        anotationView?.image = UIImage(systemName: "person")
//        anotationView?.image = UIImage(systemName: "mappin.and.ellipse")
        anotationView?.displayPriority = .defaultHigh
        anotationView?.canShowCallout = true
        
        return anotationView
    }
    
}

extension RutaViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ubicacion = locations.first else {
            return
        }
        latitud = ubicacion.coordinate.latitude
        longitud = ubicacion.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alerta = UIAlertController(title: "Error", message: "Lugar no encontrado o no se obtuvo ubicacion", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
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

extension RutaViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Eliminar la ruta y anot
        mapa.removeOverlays(mapa.overlays)
        mapa.removeAnnotations(mapa.annotations)
        
        direccionBuscarSB.resignFirstResponder()
        
        let geocoder = CLGeocoder()
        
        if let direccion = direccionBuscarSB.text {
            geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]?, error: Error?) in
                //crear el destion
                guard let destinoRuta = lugares?.first?.location else { return }
                
                if error == nil {
                    
                    let lugar = lugares?.first
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (lugar?.location?.coordinate)!
                    
                    print("Location: ",lugar?.location?.coordinate)
                    
                    anotacion.title = direccion
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.03)
                    
                    let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                    
                    self.mapa.setRegion(region, animated: true)
                    self.mapa.addAnnotation(anotacion)
                    
                    //Trazar la ruta
                    self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                }
            }//in geocoder
        }//if let direccion
    }
    
    
    
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D){
        //origen
        guard let coordOrigen = manager.location?.coordinate else { return }
        
        //Custom Anotacion
        let anotacion = MKPointAnnotation()
        anotacion.coordinate = coordOrigen
        
        anotacion.title = "Estas aqui"
        
        self.mapa.addAnnotation(anotacion)

        
        
        //Crear Origen-Destino
        let origenPlaceMark = MKPlacemark(coordinate: coordOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)
        
        //Crear un mapkit item
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        
        //solocitud de ruta
        let solicitudRuta = MKDirections.Request()
        solicitudRuta.source = origenItem
        solicitudRuta.destination = destinoItem
        
        //Como se va a viajar (pie, bici, carro)
        solicitudRuta.transportType = .automobile
        solicitudRuta.requestsAlternateRoutes = true
        
        let direcciones = MKDirections(request: solicitudRuta)
        
        direcciones.calculate { respuesta, error in
            if error != nil {
                if error?.localizedDescription == "Ruta no disponible" {
                    
                    let alerta = UIAlertController(title: "Ruta no disponible", message: "Intenta con otro lugar mas cercano", preferredStyle: .alert)
                    let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                    alerta.addAction(accionAceptar)
                    self.present(alerta, animated: true, completion: nil)
                }
                
                print("Error al calcular la ruta \(error?.localizedDescription)")
                return
            }
            
            //pintar la ruta o la linea en el mapa
            if let respuestaSegura = respuesta {
                let ruta = respuestaSegura.routes.first
                
                self.mapa.addOverlay(ruta!.polyline)
                self.mapa.setVisibleMapRect((ruta?.polyline.boundingMapRect)!, animated: true)
            }
        }
    }
}



