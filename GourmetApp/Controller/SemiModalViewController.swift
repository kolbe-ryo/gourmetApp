//
//  SemiModalViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/13.
//

import UIKit
import MapKit
import SDWebImage
import FloatingPanel
import SafariServices

class SemiModalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, FloatingPanelControllerDelegate, AlertDelegate, UINavigationControllerDelegate {
    
    // MARK:- Initial Settings
    var mapView = MKMapView()
    var floatingPanelController: FloatingPanelController!
    
    var shopData = ShopData()
    let sendDBModel = SendDBModel()
    let alertModel = AlertModel()
    
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopPlaceLabel: UILabel!
    @IBOutlet weak var shopWebSiteLabel: UILabel!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        floatingPanelController.delegate = self
        alertModel.alertDelegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        self.setPickerLayout()
        
        imageView.layer.cornerRadius = 10
    }
    
    func setShopInformtion(shopData: ShopData) {
        if let shopName = shopData.name {shopNameLabel.text = shopName}
        if let shopAddress = shopData.address {shopPlaceLabel.text = shopAddress}
        if let shopURL = shopData.url {
            if shopURL != "" {
                shopWebSiteLabel.text = shopURL
            } else {
                shopWebSiteLabel.text = "No URL"
            }
        }
    }
    
    // MARK:- Picker Delegate
    let pickerView = UIPickerView()
    let dataSource = CategoryDataSource().dataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = dataSource[row]
    }
    
    // Pickerのレイアウト設定
    func setPickerLayout() {
        pickerView.frame = CGRect(x: 0, y: self.imageTitle.frame.origin.y+20, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height*2/3)
        self.view.addSubview(pickerView)
        pickerView.isHidden = true
    }
    
    // MARK:- UI Action
    
    // ピッカー起動
    @IBAction func selectCategoryItem(_ sender: Any) {
        if pickerView.isHidden == true {
            pickerView.isHidden = false
        } else {
            pickerView.isHidden = true
        }
    }
    
    // MARK:- 画像選択ボタン
    // 写真or画像選択
    @IBAction func selectImage(_ sender: Any) {
        pickerView.isHidden = true
        let alert = alertModel.addImageAlert(title: "Image Selection", message: "Please Select Image Picker Type.", VC: self)
        self.present(alert, animated: true, completion: nil)
    }
    
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
            imageView.image = info[.originalImage] as! UIImage
            picker.dismiss(animated: true, completion: nil)
            self.imageLabel.text = "Selecting Anything."
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- Web表示ボタン
    // URLタップでサイト表示
    @IBAction func seeWebSite(_ sender: UITapGestureRecognizer) {
        if let webPage: String = shopWebSiteLabel.text {
            guard webPage != "No URL" else {return}
            let safariVC = SFSafariViewController(url: NSURL(string: webPage)! as URL)
            safariVC.modalPresentationStyle = .pageSheet
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    // MARK:- DBへ店舗登録ボタン
    // DBへお気に入り追加する(Alert内で分岐)
    @IBAction func addItemAsFavorite(_ sender: Any) {
        if categoryLabel.text == "" {
            let alert = alertModel.noResultsAlert(title: "Caution", message: "Check food category.")
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = alertModel.addFavoriteAlert(title: "Select", message: "Select Went or Want.", VC: self)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Want or Went選択終了時に実行(category:Went or Want)
    func addFavoriteToDB(category: String) {
        // DB保存用のShopData作成
        shopData.shopCategory = category
        shopData.foodCategory = categoryLabel.text
        
        // 選択画像のデータをDBModelに渡す
        let passedImage: UIImage? = imageView.image
        if let passedData = passedImage?.jpegData(compressionQuality: 0.1) {
            self.sendDBModel.sendToDB(shopData: shopData, shopImageData: passedData)
        } else {
            self.sendDBModel.sendToDB(shopData: shopData, shopImageData: Data())
        }
        let alert = alertModel.noResultsAlert(title: "Complete", message: "Add your Favorite List.")
        self.present(alert, animated: true, completion: nil)
        floatingPanelController.move(to: .half, animated: true)
    }
 
}
