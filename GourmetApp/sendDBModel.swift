//
//  sendDBModel.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/20.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

protocol SendCompletionDelegate {
    func sendCompletion()
}

class SendDBModel {
    var db = Firestore.firestore()
    var sendCompletionDelegate: SendCompletionDelegate?
    
    func sendToDB(shopData: ShopData, shopImageData: Data) {
        // 画像なしDB追加
        if shopImageData == Data() {
            self.db.collection(shopData.shopCategory!).document().setData(
                ["shopName":     shopData.name as Any,
                 "foodCategory": shopData.foodCategory as Any,
                 "latitude":     shopData.latitude as Any,
                 "longitude":    shopData.longitude as Any,
                 "telnumber":    shopData.tel as Any,
                 "shopURL":      shopData.url as Any,
                 "prefecture":   shopData.prefecture as Any,
                 "address":      shopData.address as Any,
                 "imageURL":     "",
                 "postDate":     Date().timeIntervalSince1970,
                ]
            )
            return
        }
        
        // 画像ありDB追加
        let imageRef = Storage.storage().reference().child("Images").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        // 画像保存とURL取得
        imageRef.putData(shopImageData, metadata: nil) { (metaData, error) in
            if error != nil {return}
            imageRef.downloadURL { (url, error) in
                if error != nil {return}
                // DBへ保存
                self.db.collection(shopData.shopCategory!).document().setData(
                    ["shopName":     shopData.name as Any,
                     "foodCategory": shopData.foodCategory as Any,
                     "latitude":     shopData.latitude as Any,
                     "longitude":    shopData.longitude as Any,
                     "telnumber":    shopData.tel as Any,
                     "shopURL":      shopData.url as Any,
                     "prefecture":   shopData.prefecture as Any,
                     "address":      shopData.address as Any,
                     "imageURL":     url?.absoluteString as Any,
                     "postDate":     Date().timeIntervalSince1970,
                    ]
                )
            }
        }
    }
    
    func addImageToDB(shopData: ShopData, shopImageData: Data) {
        let imageRef = Storage.storage().reference().child("Images").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        imageRef.putData(shopImageData, metadata: nil) { (metaData, error) in
            if error != nil {return}
            imageRef.downloadURL { (url, error) in
                if error != nil {return}
                
                // DB更新
                let doc = self.db.collection(shopData.shopCategory!).document(shopData.documentID!)
                doc.updateData(["imageURL":url?.absoluteString as Any]) { (error) in
                    if error != nil {return}
                    self.sendCompletionDelegate?.sendCompletion()
                }
            }
        }
    }
    
    func deleteFromDB() {
//        #error("削除処理")
    }
    
}
