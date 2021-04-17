
import Foundation
import Firebase
import FirebaseAuth

protocol LoadCompletionDelegate {
    func loadCompletion()
}

class LoadDBModel {
    
    // MARK:- Variant
    let db = Firestore.firestore()
    var shopDataSets: [ShopData] = []
    var loadCompletionDelegate: LoadCompletionDelegate?
    
    func loadContents(category: String) {
        db.collection(Auth.auth().currentUser!.uid).order(by: "postDate").addSnapshotListener {(snapShot, error) in
            if error != nil {return}
            
            self.shopDataSets = []
            if let snapShotDoc = snapShot?.documents {
                for doc in snapShotDoc {
                    if let category     = doc.data()["shopCategory"] as? String,
                       let name         = doc.data()["shopName"] as? String,
                       let foodCategory = doc.data()["foodCategory"] as? String,
                       let latitude     = doc.data()["latitude"] as? Double,
                       let longitude    = doc.data()["longitude"] as? Double,
                       let tel          = doc.data()["telnumber"] as? String,
                       let url          = doc.data()["shopURL"] as? String,
                       let prefecture   = doc.data()["prefecture"] as? String,
                       let address      = doc.data()["address"] as? String,
                       let shopImageURL = doc.data()["imageURL"] as? String,
                       let documentID   = doc.documentID as? String {
                        let newDataSets = ShopData(latitude    : latitude,
                                                   longitude   : longitude,
                                                   url         : url,
                                                   name        : name,
                                                   tel         : tel,
                                                   prefecture  : prefecture,
                                                   address     : address,
                                                   shopImageURL: shopImageURL,
                                                   shopCategory: category,
                                                   foodCategory: foodCategory,
                                                   documentID  : documentID)
                        self.shopDataSets.append(newDataSets)
                        self.shopDataSets.reverse()   
                    }
                }
                self.loadCompletionDelegate?.loadCompletion() // Notification completion
            }
        }
    }
    
}
