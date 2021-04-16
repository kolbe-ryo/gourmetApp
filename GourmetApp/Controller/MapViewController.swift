
import UIKit
import MapKit
import Lottie
import FloatingPanel

class MapViewController: UIViewController {
    
    // MARK:- Variant
    private let searchTextField = UITextField()
    private let searchButton    = UIButton()
    private let locationButton  = UIButton()
    private var latValue        = Double()
    private var logValue        = Double()
    private var shopDataArray: [ShopData] = []
    
    // Class
    private let alertModel      = AlertModel()
    private var animationView   = AnimationView()
    
    // UI Variant
    @IBOutlet weak var mapView: MKMapView!
    
    // Floating Panel
    private var floatingPanelController: FloatingPanelController!
    private var semiModalViewController: SemiModalViewController!
    
    // Location Manager
    private let locationManager = CLLocationManager()
    
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        floatingPanelController          = FloatingPanelController()
        floatingPanelController.delegate = self
        configureSubViews()
        
        // UI Setting
        self.createTextField(textField: searchTextField, hintText: "keyword", x: view.frame.width/10, y: view.frame.height*3/20)
        self.createButton(button: searchButton, name: "magnifyingglass", x: view.frame.width*17/20, y: view.frame.height*3/20, width: 35.0, height: 35.0, selector: #selector(self.search(_ :)))
        self.createButton(button: locationButton, name: "location", x: view.frame.width*16/20, y: view.frame.height*18/20, width: 50.0, height: 50.0, selector: #selector(self.myLocation(_ :)))
    }
    
    // Map Setting
    func configureSubViews() {
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter  = 50     // Update distance
        locationManager.startUpdatingLocation()  // Update location
        mapView.delegate                = self
        mapView.mapType                 = .standard
        mapView.userTrackingMode        = .follow
    }
    
    func startAnimating() {
        animationView.frame          = CGRect(x: 0, y: 0, width: view.frame.size.width/3, height: view.frame.size.width/3)
        animationView.center         = CGPoint(x: Int(view.frame.width)/2, y: Int(view.frame.height)/2)
        animationView.animation      = Animation.named("mapLoading")
        animationView.contentMode    = .scaleAspectFit
        animationView.animationSpeed = 1.0
        animationView.loopMode       = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    
    //MARK:- UI Generator
    
    // TextField
    func createTextField(textField: UITextField, hintText: String, x: CGFloat, y: CGFloat) {
        textField.frame          = CGRect(x: x, y: y, width: view.frame.width*7/10, height: 20)
        textField.font           = UIFont(name: "AvenirNext-Heavy",size: CGFloat(15))
        textField.textColor      = .darkGray
        textField.textAlignment  = .left
        textField.placeholder    = hintText
        textField.delegate       = self
        textField.addBorderBottom(height: 1.0, color: .lightGray)
        view.addSubview(textField)
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
    
    
    // MARK:- UI Action
    
    // Search and GeoCoding
    @objc func search(_ sender: UIButton) {
        guard let searchText = searchTextField.text else {return}
        if floatingPanelController != nil {floatingPanelController.removePanelFromParent(animated: true)}  // Hide floating panel
        self.startAnimating()
        self.shopDataArray = []
        self.geoCoding(searchText: searchText)
        searchTextField.resignFirstResponder()
    }
    
    // Move own location
    @objc func myLocation(_ sender: UIButton) {
        configureSubViews()
    }
    
    
    // GeoCoding API
    func geoCoding(searchText: String) {
        self.mapView.removeAnnotations(mapView.annotations)  // Remove all pin
        
        // Create searching request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region                      // Searching area size(the same to map size)

        let localSearch: MKLocalSearch = MKLocalSearch(request: request)  // Search arrangement
        localSearch.start(completionHandler: {(result, error) in          // 検索で名前なし、地理情報なしのアイテムが引っかかることがある？？？？
            if result == nil {
                let alert = self.alertModel.noResultsAlert(title: "検索結果", message: "検索結果はありませんでした。\n条件を変更して再検索して下さい。")
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // Save results
            for (id, placemark) in result!.mapItems.enumerated() {
                if error != nil {return}
                
                var shopData = ShopData()
                if let latitude:   CLLocationDegrees? = placemark.placemark.coordinate.latitude  {shopData.latitude  = latitude}
                if let longitude:  CLLocationDegrees? = placemark.placemark.coordinate.longitude {shopData.longitude = longitude}
                if let name:       String?            = placemark.name {shopData.name = name}
                if let tel:        String?            = placemark.phoneNumber {shopData.tel = tel}
                if let url:        String?            = placemark.url?.absoluteString {shopData.url = url} else {shopData.url = ""}
                if let prefecture: String?            = placemark.placemark.administrativeArea {shopData.prefecture = prefecture}
                
                shopData.address = ""
                if let prefecture = placemark.placemark.administrativeArea, let locality = placemark.placemark.locality, let thoroughfare = placemark.placemark.thoroughfare {
                    shopData.address = "\(prefecture) \(locality) \(thoroughfare)"
                }
                self.shopDataArray.append(shopData)                        // Add all searched shop data
                self.addAnnotation(id:id, placemark: placemark.placemark)  // Display pin
            }
            self.animationView.removeFromSuperview()
        })
    }
    
    func addAnnotation(id: Int, placemark: MKPlacemark) {
        let annotation        = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(placemark.coordinate.latitude, placemark.coordinate.longitude)
        annotation.title      = placemark.name
        annotation.subtitle   = String(id)
        self.mapView.addAnnotation(annotation)
    }
        
}

// MARK:- Extension

extension MapViewController: CLLocationManagerDelegate {
    // Authentication for location manager
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined                         : manager.requestWhenInUseAuthorization()
        case .restricted, .denied                   : break
        case .authorizedAlways, .authorizedWhenInUse: manager.startUpdatingLocation()
        default                                     : break
        }
    }
    
    // Method for updating location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var region: MKCoordinateRegion = mapView.region
        region.center                  = locations.last!.coordinate
        region.span.latitudeDelta      = 0.01
        region.span.longitudeDelta     = 0.01
        mapView.setRegion(region, animated:true)
    }
}


extension MapViewController: MKMapViewDelegate {
    // Pin tapped action
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        do {
            let annotationID = try Int((view.annotation?.subtitle)!!)  // Use pin's subtitle as a shop ID
            self.setSemiModalVC(id: annotationID!)
            self.setFloatingPanel(state: .half)
            // Present shop information
            self.semiModalViewController.shopData = shopDataArray[annotationID!]
            self.focusSelectedItem(mapView: self.mapView, annotationNumber: annotationID!)
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    // Setting SemiModalVC
    func setSemiModalVC(id: Int) {
        semiModalViewController                         = storyboard?.instantiateViewController(identifier: "semiMVC") as! SemiModalViewController
        semiModalViewController.shopData                = shopDataArray[id]
        semiModalViewController.mapView                 = mapView
        semiModalViewController.floatingPanelController = floatingPanelController
    }
    
    func setFloatingPanel(state: FloatingPanel.FloatingPanelState) {
        floatingPanelController.set(contentViewController: semiModalViewController)
        self.apperanceFloatingPanel()
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: state, animated: true)  // Present semiVC
    }
    
    // Focus selected pin
    func focusSelectedItem(mapView: MKMapView, annotationNumber: Int) {
        let span = mapView.region.span
        for annotation in mapView.annotations {
            if annotation.subtitle == String(annotationNumber) {
                let coordinate                     = annotation.coordinate
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                let region: MKCoordinateRegion     = MKCoordinateRegion(center: center, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func apperanceFloatingPanel() {
        let appearance                                 = SurfaceAppearance()
        appearance.cornerRadius                        = 15.0
        appearance.backgroundColor                     = .clear
        floatingPanelController.surfaceView.appearance = appearance
    }
}


extension MapViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelController()
    }
}


extension MapViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

