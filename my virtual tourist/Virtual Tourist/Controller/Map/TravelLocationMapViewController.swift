
import UIKit
import MapKit
import CoreData

class TravelLocationMapViewController: UIViewController, MKMapViewDelegate {
    
    
    
    // core data variables
    
    var dataController: DataController!
    var fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    
    @IBOutlet var mapView: MKMapView!
    
    var pins: Pin!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        load()
        // check long press and do an action through selector
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationMapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        load()
    }
    
    
    // MARK: Handling Long Press
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        newAnnotation(Coordinate: touchMapCoordinate)
    }
    
    // MARK: After The Long Press Take Location Coordinate and Make New One
    
    func newAnnotation(Coordinate: CLLocationCoordinate2D ){
        let annotation = MKPointAnnotation()
        annotation.coordinate = Coordinate
        NewPin(location: Coordinate)
        mapView.addAnnotation(annotation)
    }
    
  
    func NewPin(location: CLLocationCoordinate2D){
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = location.latitude
        newPin.longtude = location.longitude
        do{
            try dataController.viewContext.save()
            print("saved view context")
            pins = newPin
        } catch{
            print("Persist New Pin Error")
            debugPrint()
        }
    }
    
    
  
    
    func load() {
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longtude))
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPhotoAlbum"{
            let vc = segue.destination as! PhotoAlbumViewController
            vc.pined = pins
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
       // guard annotation is MKPointAnnotation else { print("nomkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinV = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinV == nil {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinV!.canShowCallout = false
            pinV!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinV!.pinTintColor = UIColor.red
        }
        else {
            pinV!.annotation = annotation
        }
        return pinV
    }
    
    

    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      
        if let Llatitude = view.annotation?.coordinate.latitude ,
           let Llongitude = view.annotation?.coordinate.longitude {
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                for pin in result {
                    if pin.latitude == Llatitude && pin.longtude == Llongitude {
                        pins = pin
                        
                       
                        self.performSegue(withIdentifier: "ToPhotoAlbum", sender: nil)
                    }
                    else {
                        print("returning")
                    }
                    
                }
            }
        }
    }
    
  
    
}

