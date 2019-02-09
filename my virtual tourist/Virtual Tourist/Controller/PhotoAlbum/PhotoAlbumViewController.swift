

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate  {
    
    

    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    

    var pined: Pin!
   
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var selectedPhoto: [IndexPath]! = []
    
    var ActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let fadeView:UIView = UIView()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
      

        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        
        collectionView.allowsMultipleSelection = false
        
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        createAnnotation()
        load()
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()
    }
    
    
    
    
    
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pined.latitude, pined.longtude)
        mapView.addAnnotation(annotation)
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pined.latitude, pined.longtude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    
    func load() {
        
       
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pined)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
            
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
    }
    
    
    
    func loadPhotos() {
        
        
        let Flicker = Api.InstanceToShared
        
        Flicker.getPhotosL(pined.latitude, pined.longtude, 30) { (success, photos) in
           
           
            
            if success == false {
                print("Unable to download images from Flickr.")
                return
            }
            
            print("Flickr images fetched : \(photos!.count)")
            
            if photos!.count == 0 {
                
                displayAlert.displayAlert(message: "This location contains no images.", title: "whops..", viewc: self)
            }
            
            
            
            photos!.forEach() { photo_url in
                let photo = Photos(context: self.dataController.viewContext)
                
                if photo.photoURL == nil {
                     print("nil value retrieved")
                }
                photo.photoURL = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pined
                
                do {
                    // Saves to CoreData
                    try self.dataController.viewContext.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
  
    
    func loadImages( imgPath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        
        let session = URLSession.shared
        let imgURL = NSURL(string: imgPath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
  
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Sorry failed to download image for \(imgPath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    

    @IBAction func newCollection(_ sender: Any) {
        if isSelectedPhotos() {
            deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                dataController.viewContext.delete(photo)
                do {
                    try dataController.viewContext.save()
                } catch {
                    print("failed to delete photo. \(error.localizedDescription)")
                }
            }
            loadPhotos()
            self.collectionView.reloadData()
        }
        
        
    }
  
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinV = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinV == nil {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinV!.canShowCallout = false
            pinV!.pinTintColor = .red
        }
        else {
            pinV!.annotation = annotation
        }
        
        return pinV
    }
   
    struct displayAlert {
        
        static func displayAlert(message: String, title: String, viewc: UIViewController)
        {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alertController.addAction(OKAction)
            
            viewc.present(alertController, animated: true, completion: nil)
        }
        
    }
} 




extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath IndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [IndexPath!])
            
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: IndexPath!)
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        }
    }
    
   
    
}


