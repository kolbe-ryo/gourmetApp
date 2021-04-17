
import UIKit

class CategoriesShopViewController: UIViewController, LoadCompletionDelegate {
    
    // MARK:- Variant
    var category = String()
    
    // CollectionView
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        return collectionView
    }()
    
    // Class
    private let imageModel   = ImageModel()
    private let categoryName = CategoryDataSource()
    private let loadDBModel  = LoadDBModel()
    
    // UI Variant
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDBModel.loadCompletionDelegate = self
        loadDBModel.loadContents(category: category)
        
        // UI Setting
        self.navigationItem.title      = category
        backgroundImage.image          = UIImage(named: imageModel.imageName.shuffled()[0])
        collectionView.delegate        = self
        collectionView.dataSource      = self
        view.addSubview(collectionView)
    }

    func loadCompletion() {
        collectionView.reloadData()
    }
 
}

// MARK:- Extension

// Data setting
extension CategoriesShopViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryName.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        cell.layer.cornerRadius = 10
        
        // ######################################
        // ######################################
        // ######################################
        // ifでwant or went の識別
        // ######################################
        
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
    
    
    func setLabel(text: String, cell: UICollectionViewCell, positionX: CGFloat, positionY: CGFloat, align: NSTextAlignment, fontSize: Int) -> UILabel {
        let label           = UILabel()
        label.numberOfLines = 0                                                                         // 行数設定
        label.frame         = CGRect(x: positionX, y: positionY, width: cell.bounds.width, height: 30)  // 位置設定
        label.textAlignment = align                                                                     // テキスト位置
        label.font          = UIFont(name: "AvenirNext-Heavy", size: CGFloat(fontSize))                 // フォントサイズ
        label.textColor     = .white                                                                    // フォント色
        
        // 取得した全てのShopデータからラベルテキストと一致するものの数をカウントする。
        var shopCount = Int()
        for shopData in loadDBModel.shopDataSets {
            if shopData.foodCategory == text {shopCount += 1}
        }
        
        if text == "" {label.text = "All\(text)"}
        if text != "" {label.text = "\(text) (\(String(shopCount)))"}
        
        return label
    }
    
}

// Action Delegate
extension CategoriesShopViewController: UICollectionViewDelegate {
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
//        selectedShopDataSets = []
//        for shopData in shopDataSets {
//            if shopData.foodCategory == categoryName.dataSource[indexPath.row] {selectedShopDataSets.append(shopData)}
//        }

        // 遷移
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
//        allVC.shopDataSets = selectedShopDataSets
        allVC.category = category
        self.navigationController?.pushViewController(allVC, animated: true)
    }
}


// Layout
extension CategoriesShopViewController: UICollectionViewDelegateFlowLayout {
    
    // CollectionCelll
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width/2
        let height = width
        return CGSize(width: width, height: height)
    }

    // Section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // Row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // Column
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
