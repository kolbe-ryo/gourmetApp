//
//  DetailShopViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/27.
//

import UIKit
import MapKit
import SDWebImage
import SafariServices

class DetailShopViewController: UIViewController, UIImagePickerControllerDelegate, AlertDelegate, UINavigationControllerDelegate, SendCompletionDelegate {
    // MARK:- Variant
    var shopData    = ShopData()
    let imageName   = ImageModel().imageName
    let alertModel  = AlertModel()
    let sendDBModel = SendDBModel()
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var webSiteLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var shopImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertModel.alertDelegate = self
        sendDBModel.sendCompletionDelegate = self
        setLayout()
    }
    
    
    @IBAction func seeWebSite(_ sender: Any) {
        guard let webPage: String = webSiteLabel.text else {return}
        guard webPage != "No URL" else {return}
        
        let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteShopFromDB(_ sender: Any) {
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
//        #error("DB削除処理")
    }
    
    // DB更新後の処理
    func sendCompletion() {
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
        allVC.loadDBModel.loadCompletionDelegate = allVC
        allVC.loadDBModel.loadContents(category: shopData.shopCategory!)
//        #error("CollectionViewの更新処理ができない")
    }
    
    // MARK:- 地図の位置調整
    
    
    // MARK:- 画像追加
    @IBAction func uploadImage(_ sender: Any) {
        let alert = alertModel.addImageAlert(title: "Image Selection", message: "Please Select Image Picker Type.", VC: self)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addFavoriteToDB(category: String) {return}
    
    func addImagepickerDelegate(imageType: String) {
        if imageType == "Camera" {self.cameraPicker()}
        if imageType == "Album" {self.albumPicker()}
    }

    func cameraPicker(){
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func albumPicker(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            shopImageView.image = info[.originalImage] as! UIImage
            picker.dismiss(animated: true, completion: nil)
            
            // DBへ追加する
            let passedImage: UIImage? = shopImageView.image
            if let passedData = passedImage?.jpegData(compressionQuality: 0.1) {
                self.sendDBModel.addImageToDB(shopData: shopData, shopImageData: passedData)
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- UI設定
    func setLayout() {
        backImage.image = UIImage(named: imageName.shuffled()[0])
        shopImageView.layer.cornerRadius = 10
        mapView.layer.cornerRadius = 10
        
        // 店舗データ設定
        shopNameLabel.text = shopData.name
        placeLabel.text    = shopData.address
        categoryLabel.text = shopData.foodCategory
        
        // URL設定
        guard let shopURL = shopData.url else {return}
        if shopURL != "" {webSiteLabel.text = shopURL}
        if shopURL == ""  {webSiteLabel.text = "No URL"}
        
        // 画像設定
        if shopData.shopImageURL != "" {shopImageView.sd_setImage(with: URL(string: shopData.shopImageURL!), completed: nil)}
        if shopData.shopImageURL == "" {shopImageView.image = UIImage(systemName:"square.and.arrow.up")}
    }
    
}
