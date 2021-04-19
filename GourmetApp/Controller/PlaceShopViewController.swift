
import UIKit

class PlaceShopViewController: UIViewController, LoadCompletionDelegate {
    
    // MARK:- Variant
    var category       = String()
    
    // Collection view
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        return collectionView
    }()
    
    // Class
    private let imageModel  = ImageModel()
    private let placeModel  = PrefectureDataSource()
    private let loadDBModel = LoadDBModel()
    
    // UI Variant
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setting
        self.navigationItem.title      = category
        backgroundImage.image          = UIImage(named: imageModel.imageName.shuffled()[0])
        collectionView.delegate        = self
        collectionView.dataSource      = self
        view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDBModel.loadCompletionDelegate = self
        loadDBModel.loadContents(category: category)
    }
    
    func loadCompletion() {collectionView.reloadData()}
    
}

// MARK:- Extension

extension PlaceShopViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        // Avoid for overlapped category
        for subview in cell.contentView.subviews{subview.removeFromSuperview()}
        
        // Category Image
        let contentImage       = UIImageView()
        let width              = cell.bounds.width*1/2
        let height             = cell.bounds.height*1/2
        contentImage.frame     = CGRect(x: (cell.bounds.width-width)/2, y: (cell.bounds.width-height)/2, width: width, height: height)
        contentImage.image     = UIImage(named: placeModel.dataSource[indexPath.row])
        cell.contentView.addSubview(contentImage)
        
        // Label Name
        let categoryLabel = self.setLabel(text: placeModel.dataSource[indexPath.row], cell: cell, positionX: 0, positionY: cell.bounds.height*8/10, align: .center, fontSize: 15)
        
        cell.contentView.addSubview(categoryLabel)
        return cell
    }
    
    func setLabel(text: String, cell: UICollectionViewCell, positionX: CGFloat, positionY: CGFloat, align: NSTextAlignment, fontSize: Int) -> UILabel {
        let label           = UILabel()
        label.numberOfLines = 0
        label.frame         = CGRect(x: positionX, y: positionY, width: cell.bounds.width, height: 30)
        label.textAlignment = align
        label.font          = UIFont(name: "AvenirNext-Heavy", size: CGFloat(fontSize))
        label.textColor     = .white
        
        // Shops counter
        var shopCount = Int()
        for shopData in loadDBModel.shopDataSets {
            if shopData.shopCategory != category {continue}
            if shopData.prefecture   == text {shopCount += 1}
        }
        
        // Set text
        if text == "" {label.text = "All\(text)"}
        if text != "" {label.text = "\(text) (\(String(shopCount)))"}
        
        return label
    }
    
}


// Action Delegate
extension PlaceShopViewController: UICollectionViewDelegate {
    // Highlight
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
    }

    // Release highlight
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .clear
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
        allVC.category       = category
        allVC.selectiveClass = "Place"
        allVC.shopPlace      = placeModel.dataSource[indexPath.row]
        self.navigationController?.pushViewController(allVC, animated: true)
    }
}


extension PlaceShopViewController: UICollectionViewDelegateFlowLayout {
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
