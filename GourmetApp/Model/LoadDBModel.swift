//
//  LoadDBModel.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/28.
//

import Foundation
import Firebase

protocol LoadCompletionDelegate {
    func loadCompletion()
}

class LoadDBModel {
    
    // MARK:- Variant
    var shopDataSets: [ShopData] = []
    let db = Firestore.firestore()
    var loadCompletionDelegate: LoadCompletionDelegate?
    
    // MARK:- Function
    func loadContents(category: String) {
        // Get all information from roomNumber collection
        db.collection(category).order(by: "postDate").addSnapshotListener { (snapShot, error) in
            if error != nil {return}
            self.shopDataSets = []
            
            // データ取得開始
            if let snapShotDoc = snapShot?.documents {
                for doc in snapShotDoc {
                    let data = doc.data()
                    
                    if let name =         data["shopName"] as? String,
                       let foodCategory = data["foodCategory"] as? String,
                       let latitude =     data["latitude"] as? Double,
                       let longitude =    data["longitude"] as? Double,
                       let tel =          data["telnumber"] as? String,
                       let url =          data["shopURL"] as? String,
                       let prefecture =   data["prefecture"] as? String,
                       let address =      data["address"] as? String,
                       let shopImageURL = data["imageURL"] as? String,
                       let documentID = doc.documentID as? String {
                        
                        let newDataSets = ShopData(latitude: latitude,
                                                   longitude: longitude,
                                                   url: url,
                                                   name: name,
                                                   tel: tel,
                                                   prefecture: prefecture,
                                                   address: address,
                                                   shopImageURL: shopImageURL,
                                                   shopCategory: category,
                                                   foodCategory: foodCategory,
                                                   documentID: documentID
                        )
                        // データセットの構成と日付順の並び替え
                        self.shopDataSets.append(newDataSets)
                        self.shopDataSets.reverse()
                        // 読み込み完了通知
                        self.loadCompletionDelegate?.loadCompletion()
                    }
                }
            }
        }
    }
    
}
