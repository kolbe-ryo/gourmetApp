//
//  SortingViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/27.
//

import UIKit
import Lottie

class SortingViewController: UIViewController, LoadCompletionDelegate {
    
    // MARK:- Variant
    var category = String()
    let imageName = ImageModel().imageName
    let loadDBModel = LoadDBModel()
    
    @IBOutlet weak var backImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = category
        setLayout()
        loadDBModel.loadCompletionDelegate = self
        loadDBModel.loadContents(category: category)
        startAnimating()
    }
    
    // Delegate: 読み込み完了時
    func loadCompletion() {
        self.animationView.removeFromSuperview()
    }
    
    // MARK:- General functions
    // 画面レイアウトの設定
    func setLayout() {
        // 背景、ボタン生成
        let shuffleImage = imageName.shuffled()
        backImage.image = UIImage(named: shuffleImage[0])
        
        let positionX = view.frame.width/9
        let positionY = view.frame.height/20
        self.generateButton(shuffleImage: shuffleImage[1], caption: "All", positionX: positionX, positionY: positionY*2.5, width: positionX*7, height: positionY*5, arrayNumber: 0, selector: #selector(self.allShop(_ :)))
        self.generateButton(shuffleImage: "14", caption: "Category", positionX: positionX, positionY: positionY*8.5, width: positionX*7, height: positionY*5, arrayNumber: 1, selector: #selector(self.categoryShop(_ :)))
        self.generateButton(shuffleImage: "15", caption: "Place", positionX: positionX, positionY: positionY*14.5, width: positionX*7, height: positionY*5, arrayNumber: 2, selector: #selector(self.placeShop(_ :)))
    }
    
    // MARK:- UI Generator
    // ボタン生成用
    func generateButton(shuffleImage: String, caption: String, positionX: CGFloat, positionY: CGFloat, width: CGFloat, height: CGFloat, arrayNumber: Int, selector: Selector) {
        // ボタンの生成
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: positionX, y: positionY, width: width, height: height)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.setBackgroundImage(UIImage(named: shuffleImage), for: .normal)
        button.setTitle(caption, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Heavy",size: CGFloat(50))
        view.addSubview(button)
        button.addTarget(self,action: selector, for: .touchUpInside)
    }
    
    // MARK:- 各ボタンのアクション設定
    // 全てのShop表示
    @objc func allShop(_ sender: UIButton) {
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
        allVC.category = category
        allVC.shopDataSets = loadDBModel.shopDataSets
        self.navigationController?.pushViewController(allVC, animated: true)
    }
    
    // カテゴリごとのShop
    @objc func categoryShop(_ sender: UIButton) {
        let categoryVC = storyboard?.instantiateViewController(withIdentifier: "categoryVC") as! CategoryShopViewController
        categoryVC.category = category
        categoryVC.shopDataSets = loadDBModel.shopDataSets
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    // 場所ごとのShop選択
    @objc func placeShop(_ sender: UIButton) {
        let placeVC = storyboard?.instantiateViewController(withIdentifier: "placeVC") as! PlaceShopViewController
        placeVC.category = category
        placeVC.shopDataSets = loadDBModel.shopDataSets
        self.navigationController?.pushViewController(placeVC, animated: true)
    }

    
    // MARK:- Lottie
    var animationView = AnimationView()
    
    // Lottieアニメーションの起動
    func startAnimating() {
        let sizeAnimation: Int = Int(view.frame.size.width/4)
        animationView.frame = CGRect(x: (Int(self.view.bounds.width)-sizeAnimation)/2, y: Int(view.frame.height*4)/10, width: sizeAnimation, height: sizeAnimation)
        animationView.animation = Animation.named("loadingForSorting")
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1.0
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
}
