//
//  CategoryShopViewController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/27.
//

import UIKit

class CategoryShopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK:- Variant
    var category = String()
    let imageName = ImageModel().imageName               // 背景の画像名呼び出し
    let categoryName = CategoryDataSource()              // 食事カテゴリの名前呼び出し
    var transitionFrom = Int()                           // 遷移画面の特定用
    var shopDataSets: [ShopData] = []                    // SortingVCで読み込んだデータ一覧の取得
    var selectedShopDataSets: [ShopData] = []            // 選択した食事カテゴリのデータセットを作成
    
    // UI Variant
    @IBOutlet weak var backImage: UIImageView!           // 背景画像変数
    @IBOutlet weak var collectionView: UICollectionView! // コレクションビューの設定
    
    // 初期設定
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = category
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        backImage.image = UIImage(named: imageName.shuffled()[0])
    }
    
    
    // MARK:- Collection View
    
    func loadCompletion() {
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryName.iconName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.layer.cornerRadius = 10
        
        // ロード際に更新されるのを防止
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
        
        // 食事カテゴリの画像設定
        let contentImage   = UIImageView()
        let width          = cell.bounds.width*1/2
        let height         = cell.bounds.height*1/2
        let positionX      = (cell.bounds.width-width)/2
        let positionY      = (cell.bounds.width-height)/2
        contentImage.frame = CGRect(x: positionX, y: positionY, width: width, height: height)
        contentImage.image = UIImage(named: categoryName.iconName[indexPath.row])
        contentImage.tintColor = .white
        cell.contentView.addSubview(contentImage)
        
        // 店舗名称の設定
        let categoryLabel =     self.setLabel(text: categoryName.dataSource[indexPath.row],
                                              cell: cell,
                                              positionX: 0,
                                              positionY: cell.bounds.height*8/10,
                                              align: .center,
                                              fontSize: 15)
        
        cell.contentView.addSubview(categoryLabel)
        
        return cell
    }
    
    // Collectionの縦横サイズ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width/2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    // セクションの上下左右の幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 行間幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // 列間幅
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // ハイライト
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
    }
    
    // ハイライト解除
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .clear
    }
    
    // 選択アクション
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // データセットの作成
        selectedShopDataSets = []
        for shopData in shopDataSets {
            if shopData.foodCategory == categoryName.dataSource[indexPath.row] {selectedShopDataSets.append(shopData)}
        }
        
        // 遷移
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
        allVC.shopDataSets = selectedShopDataSets
        self.navigationController?.pushViewController(allVC, animated: true)
    }
    
    //MARK:- Label設定
    func setLabel(text: String, cell: UICollectionViewCell, positionX: CGFloat, positionY: CGFloat, align: NSTextAlignment, fontSize: Int) -> UILabel {
        let label           = UILabel()
        label.numberOfLines = 0                                                                         // 行数設定
        label.frame         = CGRect(x: positionX, y: positionY, width: cell.bounds.width, height: 30)  // 位置設定
        label.textAlignment = align                                                                     // テキスト位置
        label.font          = UIFont(name: "AvenirNext-Heavy", size: CGFloat(fontSize))                 // フォントサイズ
        label.textColor     = .white                                                                    // フォント色
        
        // 取得した全てのShopデータからラベルテキストと一致するものの数をカウントする。
        var shopCount = Int()
        for shopData in shopDataSets {
            if shopData.foodCategory == text {shopCount += 1}
        }
        
        if text == "" {label.text = "All\(text)"}
        if text != "" {label.text = "\(text) (\(String(shopCount)))"}
        
        return label
    }
}
