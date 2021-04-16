
import UIKit
import MapKit
import SDWebImage
import FloatingPanel
import SafariServices

class SemiModalViewController: UIViewController, FloatingPanelControllerDelegate {
    
    // MARK:- Variant
    private let shopNameLabel    = UILabel()
    private let shopPlaceLabel   = UILabel()
    private let shopWebSiteLabel = UILabel()
    private let categoryTitle    = UILabel()
    private let categoryLabel    = UILabel()
    private let imageTitle       = UILabel()
    private let imageLabel       = UILabel()
    private let categoryPicker   = UIButton()
    private let imagePicker      = UIButton()
    private let imageView        = UIImageView()
    private let favoriteButton   = UIButton()
    
    // Picker
    private let pickerView       = UIPickerView()
    private let dataSource       = CategoryDataSource().dataSource
    
    // Access from mapVC
    var shopData                 = ShopData()
    var mapView                  = MKMapView()
    var floatingPanelController:   FloatingPanelController!
    
    // Class
    let sendDBModel              = SendDBModel()
    let alertModel               = AlertModel()
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        floatingPanelController.delegate = self
        alertModel.alertDelegate         = self
        
        // UI Setting
        if self.shopInformationValidate(shopData: shopData) == false {return}
        self.createLabel(label: shopNameLabel, title: shopData.name!, x: view.frame.width*1/20, y: view.frame.height*1/20, width: view.frame.width*9/10, height: 25, font: 25, color: .white)
        self.createLabel(label: shopPlaceLabel, title: shopData.address!, x: view.frame.width*1/20, y: view.frame.height*2/20, width: view.frame.width*9/10, height: 20, font: 15, color: .white)
        self.createLabel(label: shopWebSiteLabel, title: shopData.url!, x: view.frame.width*1/20, y: view.frame.height*3/20, width: view.frame.width*9/10, height: 20, font: 15, color: .cyan)
        self.createLabel(label: categoryTitle, title: "Category:", x: view.frame.width*1/20, y: view.frame.height*4/20, width: view.frame.width*3/10, height: 20, font: 15, color: .white)
        self.createLabel(label: categoryLabel, title: "No Category", x: view.frame.width*7/20, y: view.frame.height*4/20, width: view.frame.width*5/10, height: 20, font: 15, color: .white)
        self.createButton(button: categoryPicker, name: "line.horizontal.3.decrease.circle", x: view.frame.width*18/20, y: view.frame.height*4/20, width: 25, height: 25, selector: #selector(self.selectCategoryItem(_ :)))
        self.createLabel(label: imageTitle, title: "Picture  : ", x: view.frame.width*1/20, y: view.frame.height*5/20, width: view.frame.width*3/10, height: 20, font: 15, color: .white)
        self.createButton(button: imagePicker, name: "line.horizontal.3.decrease.circle", x: view.frame.width*18/20, y: view.frame.height*5/20, width: 25, height: 25, selector: #selector(self.selectImage(_ :)))
        self.createImageView(x: view.frame.width*7/20, y: view.frame.height*5/20, width: view.frame.width*5/10, height: view.frame.width*3/10)
        self.createButton(button: favoriteButton, name: "plus.rectangle.on.folder", x: view.frame.width*2/20, y: view.frame.height*6/20, width: 50, height: 50, selector: #selector(self.addItemAsFavorite(_ :)))
        
        // Tap recognizer
        shopWebSiteLabel.isUserInteractionEnabled = true
        shopWebSiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.seeWebSite(_:))))
        
        // Picker View
        pickerView.delegate = self
        pickerView.dataSource = self
        self.setPickerLayout(x: 0, y: view.frame.height*17/40, width: UIScreen.main.bounds.size.width, height: view.frame.height*3/20)
        
    }
    
    func shopInformationValidate(shopData: ShopData) -> Bool {
        if shopData.name    == nil {return false}
        if shopData.address == nil {return false}
        if shopData.url     == nil {self.shopData.url = "-"}
        return true
    }
    
    // MARK:- UI Generator
    
    // Label
    func createLabel(label: UILabel, title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, font: CGFloat, color: UIColor) {
        label.frame         = CGRect(x: x, y: y, width: width, height: height)
        label.font          = UIFont(name: "AvenirNext-Heavy", size: font)
        label.textColor     = .white
        label.textAlignment = .left
        label.textColor     = color
        label.text          = title
        view.addSubview(label)
    }
    
    // Button
    func createButton(button: UIButton, name: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, selector: Selector) {
        button.frame                      = CGRect(x: x, y: y, width: width, height: height)
        button.tintColor                  = .cyan
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment   = .fill
        button.setImage(UIImage(systemName: name), for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: selector, for: .touchUpInside)
    }
    
    // Image
    func createImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        imageView.frame              = CGRect(x: x, y: y, width: width, height: height)
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor    = .lightGray
        view.addSubview(imageView)
    }
    
    // Picker
    func setPickerLayout(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        pickerView.frame = CGRect(x: x, y: y, width: width, height: height)
        self.view.addSubview(pickerView)
        pickerView.isHidden = true
    }
    
    // MARK:- UI Action
    
    @objc func seeWebSite(_ sender: UIButton) {
        if shopWebSiteLabel.text == "" {return}
        let safariVC = SFSafariViewController(url: NSURL(string: shopWebSiteLabel.text!)! as URL)
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true, completion: nil)
    }

    // Category selection
    @objc func selectCategoryItem(_ sender: UIButton) {
        if pickerView.isHidden == true {
            pickerView.isHidden = false
        } else {
            pickerView.isHidden = true
        }
    }
 
    // Image selection
    @objc func selectImage(_ sender: UIButton) {
        pickerView.isHidden = true
        let alert = alertModel.addImageAlert(title: "Image Selection", message: "Please Select Image Picker Type.", VC: self)
        self.present(alert, animated: true, completion: nil)
    }

    // Add DB
    @objc func addItemAsFavorite(_ sender: UIButton) {
        if categoryLabel.text == "No Category" {
            let alert = alertModel.noResultsAlert(title: "Caution", message: "Check food category.")
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = alertModel.addFavoriteAlert(title: "Select", message: "Select Went or Want.", VC: self)
            self.present(alert, animated: true, completion: nil)
        }
    }
 
}

// MARK:- Extension

extension SemiModalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
}


extension SemiModalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlertDelegate {
    // Select category(category:Went or Want)
    func addFavoriteToDB(category: String) {
        // Add needed infromation for ShopData
        shopData.shopCategory = category
        shopData.foodCategory = categoryLabel.text
        
        // Send shopData to DB
        let passedImage: UIImage? = imageView.image
        if let passedData = passedImage?.jpegData(compressionQuality: 0.1) {
            self.sendDBModel.sendToDB(shopData: shopData, shopImageData: passedData)
        } else {
            self.sendDBModel.sendToDB(shopData: shopData, shopImageData: Data())
        }
        let alert = alertModel.noResultsAlert(title: "Complete", message: "Add your Favorite List!")
        self.present(alert, animated: true, completion: nil)
        floatingPanelController.move(to: .half, animated: true)
    }
    
    func addImagepickerDelegate(imageType: String) {
        if imageType == "Camera" {self.cameraPicker()}
        if imageType == "Album"  {self.albumPicker()}
    }
    
    func cameraPicker(){
        let sourceType:UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker           = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType    = sourceType
            cameraPicker.delegate      = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func albumPicker(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker           = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType    = sourceType
            cameraPicker.delegate      = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            imageView.image              = info[.originalImage] as! UIImage
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds      = true
            picker.dismiss(animated: true, completion: nil)
            self.imageLabel.text = "Selecting Anything."
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
