
import UIKit
import Firebase
import FirebaseAuth

class MainViewController: UIViewController{
    
    // MARK:- Variant
    private let addButton  = UIButton()
    private let wantButton = UIButton()
    private let wentButton = UIButton()
    // Class
    let imageModel    = ImageModel()
    // UI Variant
    @IBOutlet weak var backgroundImage: UIImageView!

    
    // MARK:- View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        
        // UI Setting
        self.createButton(button: addButton,  caption: "店を探す", x: view.frame.width/10, y: view.frame.height*6/40,  selector: #selector(self.add(_ :)), imageID: 0)
        self.createButton(button: wantButton, caption: "行きたい", x: view.frame.width/10, y: view.frame.height*17/40, selector: #selector(self.want(_ :)), imageID: 1)
        self.createButton(button: wentButton, caption: "良かった", x: view.frame.width/10, y: view.frame.height*28/40, selector: #selector(self.went(_ :)), imageID: 2)
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
    
    @objc func add(_ sender: UIButton) {
        let mapVC = storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @objc func want(_ sender: UIButton) {
        let sortVC = storyboard?.instantiateViewController(withIdentifier: "sortVC") as! SortingViewController
        sortVC.category = "Want"
        self.navigationController?.pushViewController(sortVC, animated: true)
    }
    
    @objc func went(_ sender: UIButton) {
        let sortVC = storyboard?.instantiateViewController(withIdentifier: "sortVC") as! SortingViewController
        sortVC.category = "Went"
        self.navigationController?.pushViewController(sortVC, animated: true)
    }

}

// MARK:- Extension

// Logout if back view
extension MainViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is LoginViewController {
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                return
            }
        }
    }
}
