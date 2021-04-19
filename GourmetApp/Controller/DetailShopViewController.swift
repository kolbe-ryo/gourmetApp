
import UIKit
import MapKit
import SDWebImage
import SafariServices

class DetailShopViewController: UIViewController, SendCompletionDelegate {
    
    // MARK:- Variant
    var shopData                 = ShopData()
    private let shopNameLabel    = UILabel()
    private let shopPlaceLabel   = UILabel()
    private let shopWebSiteLabel = UILabel()
    private let imageView        = UIImageView()
    private let mapView          = MKMapView()
    private let addImageButton   = UIButton() // square.and.arrow.up
    private let openMapButton    = UIButton() // map
    private let deleteDBButton   = UIButton() // delete.left
    
    // Class
    private let imageModel       = ImageModel()
    private let alertModel       = AlertModel()
    private let sendDBModel      = SendDBModel()
    
    // UI Variant
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title          = "Shop Information"
        alertModel.alertDelegate           = self
        sendDBModel.sendCompletionDelegate = self
        
        // UI Setting
        backgroundImage.image          = UIImage(named: imageModel.imageName.shuffled()[0])
        self.configureMapView(latitude: shopData.latitude!, longitude: shopData.longitude!)
        self.createLabel(label: shopNameLabel, title: shopData.name!, x: view.frame.width/20, y: view.frame.height*5/40, width: view.frame.width*18/20, height: 30, font: 25, color: .white)
        self.createLabel(label: shopPlaceLabel, title: shopData.address!, x: view.frame.width/20, y: view.frame.height*7/40, width: view.frame.width*18/20, height: 30, font: 15, color: .white)
        self.createLabel(label: shopWebSiteLabel, title: shopData.url!, x: view.frame.width/20, y: view.frame.height*9/40, width: view.frame.width*18/20, height: 30, font: 15, color: .cyan)
        self.createImageView(x: view.frame.width/20, y: view.frame.height*11/40, width: view.frame.width*18/20, height: view.frame.height*3/10)
        self.createButton(button: addImageButton, name: "square.and.arrow.up", x: view.frame.width*3/20, y: view.frame.height*37/40, width: 30, height: 30, selector: #selector(self.uploadImage(_ :)))
        self.createButton(button: openMapButton, name: "map", x: view.frame.width*19/40, y: view.frame.height*37/40, width: 30, height: 30, selector: #selector(self.activateMap(_ :)))
        self.createButton(button: deleteDBButton, name: "delete.left", x: view.frame.width*31/40, y: view.frame.height*37/40, width: 30, height: 30, selector: #selector(self.deleteShop(_ :)))
        
        // Tap recognizer
        shopWebSiteLabel.isUserInteractionEnabled = true
        shopWebSiteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.seeWebSite(_:))))
    }
    

    // MARK:- UI Generator
    
    // MapView
    func configureMapView(latitude:CLLocationDegrees, longitude:CLLocationDegrees) {
        mapView.frame = CGRect(x: view.frame.width/20, y: view.frame.height*24/40, width: view.frame.width*18/20, height: view.frame.height*3/10)
        mapView.layer.cornerRadius = 10
        
        // Coordinate setting
        let cordinate  = CLLocationCoordinate2DMake(latitude, longitude)
        let span       = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region     = MKCoordinateRegion(center: cordinate, span: span)
        mapView.region = region
        
        // Pin setting
        let pin        = MKPointAnnotation()
        pin.title      = shopData.name
        pin.coordinate = cordinate
        mapView.addAnnotation(pin)
        
        view.addSubview(mapView)
    }
    
    // Label
    func createLabel(label: UILabel, title: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, font: CGFloat, color: UIColor) {
        label.frame         = CGRect(x: x, y: y, width: width, height: height)
        label.font          = UIFont(name: "AvenirNext-Heavy", size: font)
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
        imageView.clipsToBounds      = true
        imageView.backgroundColor    = .lightGray
        imageView.sd_setImage(with: URL(string: shopData.shopImageURL!), completed: nil)
        view.addSubview(imageView)
    }
    
    
    // MARK:- UI Action
    
    @objc func seeWebSite(_ sender: UIButton) {
        if shopWebSiteLabel.text == "" {return}
        let safariVC = SFSafariViewController(url: NSURL(string: shopWebSiteLabel.text!)! as URL)
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true, completion: nil)
    }
    
    @objc func uploadImage(_ sender: UIButton) {
        let alert = alertModel.addImageAlert(title: "Image Selection", message: "Please Select Image Picker Type.", VC: self)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func activateMap(_ sender: UIButton) {
        var urlString = String()
        urlString     = shopData.name!.replacingOccurrences(of: " ", with: "+")
        urlString     = "http://maps.apple.com/?q=\(urlString)&sll=\(shopData.latitude!),\(shopData.longitude!)"
        if let url    = URL(string: urlString) {UIApplication.shared.open(url)}
    }
    
    @objc func deleteShop(_ sender: UIButton) {
        sendDBModel.deleteFromDB(documentID: shopData.documentID!)
    }
    
}

// MARK:- Extension

extension DetailShopViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlertDelegate {
    
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
            imageView.image = info[.originalImage] as! UIImage
            picker.dismiss(animated: true, completion: nil)

            // Add DB
            let passedImage: UIImage? = imageView.image
            if let passedData = passedImage?.jpegData(compressionQuality: 0.1) {
                self.sendDBModel.addImageToDB(shopData: shopData, shopImageData: passedData)
            }
        }
    }
    
    func sendCompletion() {
        let alert = alertModel.noResultsAlert(title: "Complete", message: "Add your Favorite List!")
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
