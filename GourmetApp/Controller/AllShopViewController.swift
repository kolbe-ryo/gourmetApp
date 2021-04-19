
import UIKit
import SDWebImage

class AllShopViewController: UIViewController, LoadCompletionDelegate {
    
    // MARK:- Variant
    var category                     = String()  // Want, Good
    var selectiveClass               = String()  // All, Category, Place
    var foodCategory                 = String()  // Selected food category
    var shopPlace                    = String()  // Selected place
    private var shopData: [ShopData] = []
    
    // CollectionView
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        return collectionView
    }()
    
    // Class
    private let imageModel  = ImageModel()
    private let loadDBModel = LoadDBModel()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func loadCompletion() {collectionView.reloadData()}

}


// MARK:- Extension

extension AllShopViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shopData = []
        for data in loadDBModel.shopDataSets {
            if data.shopCategory != category {continue}
            if self.selectiveClass == "All" {self.shopData.append(data)}
            if self.selectiveClass == "Category", self.foodCategory == data.foodCategory {self.shopData.append(data)}
            if self.selectiveClass == "Place", self.shopPlace == data.prefecture {self.shopData.append(data)}
        }
        return self.shopData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)

        // Avoid for overlapped category
        for subview in cell.contentView.subviews{subview.removeFromSuperview()}

        let nameLabel     = self.setLabel(text: shopData[indexPath.row].name!, x: cell.bounds.width*1/10, y: 0, width: cell.frame.width*9/10, height: cell.frame.height*8/10, lines: 3, align: .left, fontSize: 30, color: .white)
        let placeLabel    = self.setLabel(text: shopData[indexPath.row].prefecture!, x: cell.bounds.width*1/10, y: cell.bounds.height*8/10, width: cell.frame.width*9/10, height: cell.frame.height/10, lines: 0, align: .left, fontSize: 15, color: .black)
        let categoryLabel = self.setLabel(text: shopData[indexPath.row].foodCategory!, x: cell.bounds.width*1/10, y: cell.bounds.height*9/10, width: cell.frame.width*9/10, height: cell.frame.height/10, lines: 0, align: .left, fontSize: 15, color: .black)
        
        cell.contentView.addSubview(nameLabel)
        cell.contentView.addSubview(placeLabel)
        cell.contentView.addSubview(categoryLabel)
        return cell
    }
    
    func setLabel(text: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, lines: Int, align: NSTextAlignment, fontSize: Int, color: UIColor) -> UILabel {
        let label           = UILabel()
        label.numberOfLines = lines
        label.frame         = CGRect(x: x, y: y, width: width, height: height)
        label.textAlignment = align
        label.font          = UIFont(name: "AvenirNext-Heavy", size: CGFloat(fontSize))
        label.textColor     = color
        label.text          = text
        return label
    }
    
}


// Action Delegate
extension AllShopViewController: UICollectionViewDelegate {
    // Highlight
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
    }

    // Release highlight
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC      = storyboard?.instantiateViewController(withIdentifier: "detailVC") as! DetailShopViewController
        detailVC.shopData = self.shopData[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}


extension AllShopViewController: UICollectionViewDelegateFlowLayout {
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
