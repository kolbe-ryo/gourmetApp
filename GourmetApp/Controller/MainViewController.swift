//
//  MainViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/01/17.
//

import UIKit
import Firebase
import FirebaseAuth


class MainViewController: UIViewController {
    // MARK:- Variant
    @IBOutlet weak var backImage: UIImageView!
    
    
    // Image
    let backimageName: Array = ["1", "2", "3", "4", "5"]
    let buttonImageName: Array = ["6", "7", "8", "9", "10", "11", "12", "13"]

    // MARK:- View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    // MARK:- General functions
    // 画面レイアウトの設定
    func setLayout() {
        self.navigationController?.isNavigationBarHidden = false
        // 背景画像
        backImage.image = UIImage(named: backimageName.randomElement()!)
        // ボタン生成
        let positionX = view.frame.width/9
        let positionY = view.frame.height/20
        let shuffleImage = buttonImageName.shuffled()
        self.generateButton(shuffleImage: shuffleImage[0], caption: "Add", positionX: positionX, positionY: positionY*2.5, width: positionX*7, height: positionY*5, arrayNumber: 0, selector: #selector(self.add(_ :)))
        self.generateButton(shuffleImage: shuffleImage[1], caption: "Want", positionX: positionX, positionY: positionY*8.5, width: positionX*7, height: positionY*5, arrayNumber: 1, selector: #selector(self.want(_ :)))
        self.generateButton(shuffleImage: shuffleImage[2], caption: "Went", positionX: positionX, positionY: positionY*14.5, width: positionX*7, height: positionY*5, arrayNumber: 2, selector: #selector(self.went(_ :)))
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
    // 追加
    @objc func add(_ sender: UIButton) {
        let mapVC = storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // 行きたい
    @objc func want(_ sender: UIButton) {
        let sortVC = storyboard?.instantiateViewController(withIdentifier: "sortVC") as! SortingViewController
        sortVC.category = "Want"
        self.navigationController?.pushViewController(sortVC, animated: true)
    }
    
    // 良かった
    @objc func went(_ sender: UIButton) {
        let sortVC = storyboard?.instantiateViewController(withIdentifier: "sortVC") as! SortingViewController
        sortVC.category = "Went"
        self.navigationController?.pushViewController(sortVC, animated: true)
    }

}
