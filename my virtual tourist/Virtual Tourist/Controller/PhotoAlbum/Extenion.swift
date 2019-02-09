

import Foundation
import UIKit


extension PhotoAlbumViewController: UICollectionViewDelegate , UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
      
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let data = photo.imageData {
            cell.image.image = UIImage(data: data)
        } else {
            cell.image.image = UIImage(named: "image")
            cell.contentView.alpha = 1.0

            // Call Download Image Method
            loadImages(imgPath: photo.photoURL!) { imageData, errorString in
                if let imageData = imageData {
                    DispatchQueue.main.async {
                        cell.image.image = UIImage(data: imageData)
                    }
                    photo.imageData = imageData
                    try? self.dataController.viewContext.save()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Changes photo opacity
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 0.4
        
        if selectedPhoto.contains(indexPath) == false {
            selectedPhoto.append(indexPath)
        }
        selectPhotoLayoutButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        // Changes photo opacity
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1.0
        
        if let index = selectedPhoto.firstIndex(of: indexPath) {
            selectedPhoto.remove(at: index)
        }
        selectPhotoLayoutButton()
    }

    
   
    func selectPhotoLayoutButton() {
        if isSelectedPhotos() {
            newCollectionButton.title = "Delete Selected Photos"
            newCollectionButton.tintColor = .red
        }
        else {
            newCollectionButton.title = "Update Collection"
            newCollectionButton.tintColor = .blue
        }
    }
    
   
    func isSelectedPhotos() -> Bool {
        if selectedPhoto.count == 0 {
            return false
        }
        return true
    }
    
    
    func deleteSelectedPhotos() {
        let photos = selectedPhoto.map() { fetchedResultsController.object(at: $0) }
        photos.forEach() { photo in
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        
        selectedPhoto.removeAll()
        selectPhotoLayoutButton()
    }
}

