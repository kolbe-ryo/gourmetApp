//
//  PlaceShopViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/27.
//

import UIKit

class PlaceShopViewController: UIViewController {
    // MARK:- Variant
    var category = String()
    var transitionFrom = Int()
    let imageName = ImageModel().imageName
    var shopDataSets: [ShopData] = []

    @IBOutlet weak var backImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = category
        self.navigationItem.backButtonTitle = "Back"
        backImage.image = UIImage(named: imageName.shuffled()[0])
    }
    
}
