//
//  MapViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/07.
//

import UIKit
import MapKit
import Lottie
import FloatingPanel

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, FloatingPanelControllerDelegate {
    
    // MARK:- Variant
    private let searchTextField = UITextField()
    private let searchButton    = UIButton()
    private let locationButton  = UIButton()
    private var latValue        = Double()
    private var logValue        = Double()
    // Class
    private let alertModel      = AlertModel()
    private var animationView   = AnimationView()
    // UI Variant
    @IBOutlet weak var mapView: MKMapView!
    // API Variant
    private var shopDataArray: [ShopData] = []
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
        textField.addBorderBottom(height: 1.0, color: .darkGray)
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
    
    // 入力情報検索&API起動
    @objc func search(_ sender: UIButton) {
        guard let searchText = searchTextField.text else {return}
        if floatingPanelController != nil {floatingPanelController.removePanelFromParent(animated: true)}
        self.startAnimating()
        self.geoCoding(searchText: searchText)
        searchTextField.resignFirstResponder()
    }
    
    // 現在位置に移動して表示
    @objc func myLocation(_ sender: UIButton) {
        configureSubViews()
    }
    
    
    // MARK:- Location Manager
    
    
    // ローケーションの設定
    func configureSubViews() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // 指定M移動ごとに更新
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
    }
    
    // 位置情報の認証
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied: break
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default: break
        }
    }
    
    // 位置情報取得時に呼ばれる画面更新メソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var region: MKCoordinateRegion = mapView.region
        region.center = locations.last!.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        mapView.setRegion(region, animated:true)
    }
    
    // 検索位置への移動

    
    func geoCoding(searchText: String) {
        if searchTextField.text == nil {return}
        // 全てのピンを削除する
        self.mapView.removeAnnotations(mapView.annotations)
        
        // 検索条件を作成する。
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        
        // 検索範囲はマップビューと同じにする。
        request.region = mapView.region
        
        // ローカル検索を実行する。
        let localSearch:MKLocalSearch = MKLocalSearch(request: request)
        var count = 0
        
        // 検索で名前なし、地理情報なしのアイテムが引っかかることがある？？？？
        localSearch.start(completionHandler: {(result, error) in
            if result != nil {
                for placemark in result!.mapItems {
                    if(error == nil) {
                        // 取得情報を配列に保存
                        var shopData = ShopData()
                        if let latitude: CLLocationDegrees? = placemark.placemark.coordinate.latitude {shopData.latitude = latitude}
                        if let longitude: CLLocationDegrees? = placemark.placemark.coordinate.longitude {shopData.longitude = longitude}
                        if let name = placemark.name {shopData.name = name}
                        if let tel = placemark.phoneNumber {shopData.tel = tel}
                        if let url = placemark.url?.absoluteString {shopData.url = url} else {shopData.url = ""}
                        if let prefecture = placemark.placemark.administrativeArea {
                            shopData.prefecture = prefecture
                            if let locality = placemark.placemark.locality, let thoroughfare = placemark.placemark.thoroughfare {
                                shopData.address = "\(prefecture) \(locality) \(thoroughfare)"
                            } else {shopData.address = ""}
                        }
                        self.shopDataArray.append(shopData)
                                                
                        // ピンの表示
                        self.addAnnotation(count:count, placemark: placemark.placemark)
                        count += 1
                    } else {
                        print(error.debugDescription)
                    }
                }
            } else {
                let alert = self.alertModel.noResultsAlert(title: "検索結果", message: "検索結果はありませんでした。\n条件を変更して再検索して下さい。")
                self.present(alert, animated: true, completion: nil)
            }
            // 検索完了時、検索アニメーション停止
            self.animationView.removeFromSuperview()
        })
    }
    
    // ピンの追加
    func addAnnotation(count: Int, placemark: MKPlacemark) {
        //検索された場所にピンを刺す。
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(placemark.coordinate.latitude, placemark.coordinate.longitude)
        annotation.title = placemark.name
        annotation.subtitle = String(count)
        self.mapView.addAnnotation(annotation)
    }
    
    // ピンタップ時にモーダルをフルにして情報を表示
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // semiModalVCを
        guard let annotationID = Int((view.annotation?.subtitle)!!) else {return}
        self.setSemiModalVC(count: annotationID)
        self.setFloatingPanel(state: .half)
        // Shop情報を表示する
        self.semiModalViewController.setShopInformtion(shopData: shopDataArray[annotationID])
        self.focusSelectedItem(mapView: self.mapView, annotationNumber: annotationID)
    }
    
    
    // MARK:- 検索情報をセミモーダルに表示する。
    func setFloatingPanel(state: FloatingPanel.FloatingPanelState) {
        // ハーフモーダルをsemiVCへ繋げる
        floatingPanelController.set(contentViewController: semiModalViewController)
        // 見た目の設定
        floatingPanelController.backdropView.backgroundColor = .clear
        self.apperanceFloatingPanel()
        // セミモーダルビューを表示する
        floatingPanelController.addPanel(toParent: self)
        floatingPanelController.move(to: state, animated: true)
    }

    // 見た目の変更
    func apperanceFloatingPanel() {
        // カラー&角丸
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        
        // 影の設定
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        floatingPanelController.surfaceView.appearance = appearance
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return CustomFloatingPanelController()
    }
    
    // ハーフモーダル内で選択したアイテムにフォーカス
    func focusSelectedItem(mapView: MKMapView, annotationNumber: Int) {
        let span = mapView.region.span
        for annotation in mapView.annotations {
            if annotation.subtitle == String(annotationNumber) {
                let coordinate = annotation.coordinate
                let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
                mapView.setCenter(center, animated: true)
                let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
                
                // 選択した店を中心に持ってくる
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    // SemiModalVCのセットアップ
    func setSemiModalVC(count: Int) {
        semiModalViewController = storyboard?.instantiateViewController(identifier: "semiMVC") as! SemiModalViewController
        semiModalViewController.shopData = shopDataArray[count]
        semiModalViewController.mapView = mapView
        semiModalViewController.floatingPanelController = floatingPanelController
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
