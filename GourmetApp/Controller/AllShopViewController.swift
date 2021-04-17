//
//  AllShopViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/27.
//

import UIKit
import SDWebImage

class AllShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoadCompletionDelegate {
    
    // MARK:- Variant
    var category                 = String()
    var shopDataSets: [ShopData] = []
    let imageName                = ImageModel().imageName
    
    let loadDBModel              = LoadDBModel()

    @IBOutlet weak var backImage     : UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    // ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    // loadDBModelの再読み込み必要＋popView(categoryVC or placeVC)の際に更新されたDBを受け渡す必要あり
    
//    #error("loadDBModelの再読み込み必要＋popView(categoryVC or placeVC)の際に更新されたDBを受け渡す必要あり")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = category
        backImage.image           = UIImage(named: imageName.shuffled()[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDBModel.loadCompletionDelegate = self
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    func loadCompletion() {}

    // MARK:- Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopDataSets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell                = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.cornerRadius = 20
        cell.backgroundColor    = .darkGray
        
        for subview in cell.contentView.subviews{subview.removeFromSuperview()}  // 読み込む毎に追加されるのを防止
        // Imageの設定
        var contentImage   = UIImageView()
        contentImage.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        cell.contentView.addSubview(contentImage)
        
        if shopDataSets[indexPath.row].shopImageURL != "" {
            contentImage.sd_setImage(with: URL(string: shopDataSets[indexPath.row].shopImageURL!), completed: nil)
        }
        
        // 店舗名称の設定
        let shopNameLabel     = self.setLabel(text: shopDataSets[indexPath.row].name!,
                                              cell: cell,
                                              positionX: 0,
                                              positionY: cell.bounds.height*8/10,
                                              fontSize: 16)
        let foodCategoryLabel = self.setLabel(text: shopDataSets[indexPath.row].foodCategory!,
                                              cell: cell,
                                              positionX: 0,
                                              positionY: cell.bounds.height/10,
                                              fontSize: 11)
        let shopPlaceLabel    = self.setLabel(text: shopDataSets[indexPath.row].prefecture!,
                                              cell: cell,
                                              positionX: 0,
                                              positionY: cell.bounds.height*2/10,
                                              fontSize: 11)
        
        cell.contentView.addSubview(shopNameLabel)
        cell.contentView.addSubview(foodCategoryLabel)
        cell.contentView.addSubview(shopPlaceLabel)
        return cell
    }
    
    // Collectionの縦横サイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width/2-15
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // セクションの上下左右の幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    // 行間幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // 列間幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // ハイライト
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
    }
    
    // ハイライト解除
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .darkGray
    }
    
    // 選択アクション
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailShopViewController
        detailVC.shopData              = shopDataSets[indexPath.row]
        detailVC.shopData.shopCategory = category
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK:- Label設定
    func setLabel(text: String, cell: UICollectionViewCell, positionX: CGFloat, positionY: CGFloat, fontSize: Int) -> UILabel {
        let label           = UILabel()
        label.frame         = CGRect(x: positionX, y: positionY, width: cell.bounds.width-5, height: 20)
        label.textAlignment = .right
        label.text          = text
        label.font          = UIFont(name: "AvenirNext-Heavy",size: CGFloat(fontSize))
        label.textColor     = .white
        return label
    }

}
