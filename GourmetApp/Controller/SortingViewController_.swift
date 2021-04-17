
import UIKit

class SortingViewController: UIViewController {
    
    // MARK:- Variant
    var category               = String()
    private let allButton      = UIButton()
    private let categoryButton = UIButton()
    private let placeButton    = UIButton()
    
    // Class
    let imageModel  = ImageModel()
    
    // UI Variant
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = category

        // UI Setting
        self.createButton(button: allButton, caption: "All", x: view.frame.width/10, y: view.frame.height*6/40, selector: #selector(self.all(_ :)), imageID: 0)
        self.createButton(button: categoryButton, caption: "Category", x: view.frame.width/10, y: view.frame.height*17/40, selector: #selector(self.category(_ :)), imageID: 1)
        self.createButton(button: placeButton, caption: "Place", x: view.frame.width/10, y: view.frame.height*28/40, selector: #selector(self.place(_ :)), imageID: 2)
        backgroundImage.image = UIImage(named: imageModel.imageName.shuffled()[0])
    }

    
    // MARK:- UI Generator

    // Button
    func createButton(button: UIButton, caption: String, x: CGFloat, y: CGFloat, selector: Selector, imageID: Int) {
        button.frame              = CGRect(x: x, y: y, width: view.frame.width*8/10, height: view.frame.height*5/20)
        button.titleLabel?.font   = UIFont(name: "AvenirNext-Heavy",size: CGFloat(50))
        button.layer.cornerRadius = 15
        button.clipsToBounds      = true
        button.setBackgroundImage(UIImage(named: imageModel.imageName.shuffled()[imageID]), for: .normal)
        button.setTitle(caption, for: .normal)
        view.addSubview(button)
        button.addTarget(self,action: selector, for: .touchUpInside)
    }
    
    
    // MARK:- UI Action
    // 全てのShop表示
    @objc func all(_ sender: UIButton) {
        let allVC = storyboard?.instantiateViewController(withIdentifier: "allVC") as! AllShopViewController
        allVC.category = category
        self.navigationController?.pushViewController(allVC, animated: true)
    }
    
    // カテゴリごとのShop
    @objc func category(_ sender: UIButton) {
        let categoryVC = storyboard?.instantiateViewController(withIdentifier: "categoryVC") as! CategoriesShopViewController
        categoryVC.category = category
        self.navigationController?.pushViewController(categoryVC, animated: true)
    }
    
    // 場所ごとのShop選択
    @objc func place(_ sender: UIButton) {
        let placeVC = storyboard?.instantiateViewController(withIdentifier: "placeVC") as! PlaceShopViewController
        placeVC.category = category
        self.navigationController?.pushViewController(placeVC, animated: true)
    }
    
}
