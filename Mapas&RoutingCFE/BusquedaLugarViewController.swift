//
//  BusquedaLugarViewController.swift
//  Mapas&RoutingCFE
//
//  Created by marco rodriguez on 10/08/22.
//

import UIKit
import MapKit

class BusquedaLugarViewController: UIViewController {
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var busquedaLugarSB: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        busquedaLugarSB.delegate = self
        
        //Cual sera el primer obj en responder a la interaccion del usuario
        busquedaLugarSB.becomeFirstResponder()
    }

}

// MARK: - SearchBar
extension BusquedaLugarViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //ocultar el teclado
        busquedaLugarSB.resignFirstResponder()
        
        //Quitar las anotaciones
        mapa.removeAnnotations(mapa.annotations)
        
        let geocoder = CLGeocoder() //para convertir entre lugar y coordenadas
        
        //crear un lugar para buscar que sea el texto que el usuario escribe
        if busquedaLugarSB.text != "" {
            if let direccion = busquedaLugarSB.text {
                geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]?, error: Error?) in
                    print("Lugares encontrados: \(lugares?.count)")
                    //validar si hubo errro
                    if error != nil {
                        print(error!.localizedDescription)
                        
                        let alerta = UIAlertController(title: "Lugar o direccion no encontrado", message: "", preferredStyle: .alert)
                        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                       
                        alerta.addAction(accionAceptar)
                        
                        self.present(alerta, animated: true, completion: nil)
                    }// if error
                    
                    //Crear el lugar a mostrar
                    if let lugar = lugares?.first {
                        
                        // crear la anotacion que tendra las coordenadas, span y la region
                        let anotacion = MKPointAnnotation()
                        anotacion.coordinate = lugar.location?.coordinate ?? CLLocationCoordinate2D(latitude: 19.43, longitude: -101.495)
                        anotacion.title = direccion
                        anotacion.subtitle = "Lat: \(lugar.location!.coordinate.latitude) ,Lon: \(lugar.location!.coordinate.longitude)"
                        
                        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                        
                        self.mapa.setRegion(region, animated: true)
                        self.mapa.addAnnotation(anotacion)
                        
                        self.mapa.selectAnnotation(anotacion, animated: true)
                        
                    }
                    
                    
                }//closure geocoder
            }//if let direccion
        }
        
    }
}
