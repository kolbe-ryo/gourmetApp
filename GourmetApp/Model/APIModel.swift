//
//  APIModel.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/07.
//

import Foundation
import Alamofire
import SwiftyJSON

// データ読み込み完了プロトコル
protocol DoneCatchDataProtocol {
    func catchData(arrayData: Array<ShopData>, resultCount: Int)
}

// Class
class AnalyticsModel {
    
    // MARK:- Variant
    var latValue: Double?
    var logValue: Double?
    var urlString: String?
    var shopDataArray: [ShopData] = []
    var doneCatchDataProtocol: DoneCatchDataProtocol?
    
    // MARK:- Initialize
    init(latitude: Double, longitude: Double, url: String) {
        latValue = latitude
        logValue = longitude
        urlString = url
    }
    
    
    // JSON analysis
    func setData() {
        // URLエンコード（日本語などURLで指示できないものを含む時）
        if let encodeURLString: String = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // リクエスト
            AF.request(encodeURLString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { [self] (response) in
                switch response.result {
                case .success:
                    do {
                        let json: JSON = try JSON(data: response.data!)
                        
                        // 検索結果が0の時はすぐに返す
                        guard var totalHitCount:Int = json["total_hit_count"].int else{
                            self.doneCatchDataProtocol?.catchData(arrayData: self.shopDataArray, resultCount: 0)
                            return
                        }
                        
                        if totalHitCount >= 50 {totalHitCount = 50}
                        
                        
                        for i in 0...totalHitCount-1 {
                            
                            if json["rest"][i]["latitude"] != "" && json["rest"][i]["longitude"] != "" && json["rest"][i]["url"] != "" && json["rest"][i]["name"] != "" && json["rest"][i]["tel"] != "" && json["rest"][i]["shop_image"] != "" {
                                
                                
                                let shopData = ShopData(latitude: json["rest"][i]["latitude"].double, longitude: json["rest"][i]["longitude"].double, url: json["rest"][i]["url"].string, name: json["rest"][i]["name"].string, tel: json["rest"][i]["tel"].string, shopImageURL: json["rest"][i]["image_url"]["shop_image1"].string)
                                
                                self.shopDataArray.append(shopData)
                                
                            }else {
                                print("Anything is empty...")
                            }
                            
                        }
                        
//                        print(self.shopDataArray)
                        
                        // Activate Delegate method
                        self.doneCatchDataProtocol?.catchData(arrayData: self.shopDataArray, resultCount: self.shopDataArray.count)
                        
                    } catch  {
                        print("Error!")
                    }
                    break
                
                // Act for error
                case .failure: break
                    
                }
                
            }
        }
    }
    
    // Send analysis value to controller
    
}
