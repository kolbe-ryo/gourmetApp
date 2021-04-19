
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

protocol SendCompletionDelegate {
    func sendCompletion()
    func deleteCompletion()
}

class SendDBModel {
    var db = Firestore.firestore()
    var sendCompletionDelegate: SendCompletionDelegate?
    
    func sendToDB(shopData: ShopData, shopImageData: Data) {
        var shopDataArray = ["shopCategory": shopData.shopCategory as Any,
                             "shopName"    : shopData.name as Any,
                             "foodCategory": shopData.foodCategory as Any,
                             "latitude"    : shopData.latitude  as Any,
                             "longitude"   : shopData.longitude as Any,
                             "telnumber"   : shopData.tel as Any,
                             "shopURL"     : shopData.url as Any,
                             "prefecture"  : shopData.prefecture as Any,
                             "address"     : shopData.address as Any,
                             "imageURL"    : "",
                             "postDate"    : Date().timeIntervalSince1970] as [String : Any]
        
        // No image
        if shopImageData == Data() {
            self.db.collection(Auth.auth().currentUser!.uid).document().setData(shopDataArray)
            return
        }
        
        // Exist image
        let imageRef = Storage.storage().reference().child("Images").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        imageRef.putData(shopImageData, metadata: nil){ (metaData, error) in
            if error != nil {return}
            imageRef.downloadURL{ (url, error) in
                if error != nil {return}
                // urlは直前まで常にnilの為、代入不可
                self.db.collection(Auth.auth().currentUser!.uid).document().setData(
                    ["shopCategory": shopData.shopCategory as Any,
                     "shopName"    : shopData.name as Any,
                     "foodCategory": shopData.foodCategory as Any,
                     "latitude"    : shopData.latitude  as Any,
                     "longitude"   : shopData.longitude as Any,
                     "telnumber"   : shopData.tel as Any,
                     "shopURL"     : shopData.url as Any,
                     "prefecture"  : shopData.prefecture as Any,
                     "address"     : shopData.address as Any,
                     "imageURL"    : url?.absoluteString as Any,
                     "postDate"    : Date().timeIntervalSince1970] as [String : Any]
                )
            }
        }
    }
    
    func addImageToDB(shopData: ShopData, shopImageData: Data) {
        // Delete
        let imageRefForDelete = Storage.storage().reference(forURL: shopData.shopImageURL!)
        imageRefForDelete.delete(completion: { (error) in
            if error != nil {return}
        })
        
        // Add
        let imageRef = Storage.storage().reference().child("Images").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        imageRef.putData(shopImageData, metadata: nil) { (metaData, error) in
            if error != nil {return}
            imageRef.downloadURL { (url, error) in
                if error != nil {return}
                
                // Update DB
                let doc = self.db.collection(Auth.auth().currentUser!.uid).document(shopData.documentID!)
                doc.updateData(["imageURL":url?.absoluteString as Any]) { (error) in
                    if error != nil {return}
                    self.sendCompletionDelegate?.sendCompletion()
                }
            }
        }
    }
    
    func deleteFromDB(documentID: String) {
        db.collection(Auth.auth().currentUser!.uid).document(documentID).delete { (error) in
            if error != nil {return}
            self.sendCompletionDelegate?.deleteCompletion()
        }
    }
    
}
