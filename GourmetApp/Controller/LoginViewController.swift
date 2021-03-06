
import UIKit
import Lottie
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK:- Variant
    private let titleLabel        = UILabel()
    private let emailTextField    = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton      = UIButton()
    private let logInButton       = UIButton()
    
    // Class
    private let alertModel        = AlertModel()
    private let imageModel        = ImageModel()
    private var animationView     = AnimationView()
    
    // UI Variant
    @IBOutlet weak var backgoundImage: UIImageView!
    
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor    = .white
        self.navigationController?.navigationBar.barTintColor = .darkGray
        self.startAnimating()
        
        // UI Setting
        self.createLabel()
        self.createTextField(textField: emailTextField, hintText: "E-Mail Address", x: view.frame.width/10, y: view.frame.height*4/10)
        self.createTextField(textField: passwordTextField, hintText: "Password", x: view.frame.width/10, y: view.frame.height*5/10)
        self.createButton(button: signInButton, caption: "SignIn", x: view.frame.width*2/10, y: view.frame.height*6/10, selector: #selector(self.signIn(_ :)))
        self.createButton(button: logInButton, caption: "LogIn", x: view.frame.width*5/10, y: view.frame.height*6/10, selector: #selector(self.logIn(_ :)))
        backgoundImage.image = UIImage(named: imageModel.imageName.shuffled()[0])
        
        // Mail Authentication Check
        self.checkAuthenticateMail()
    }
    
    
    // Start Waiting Animation
    func startAnimating() {
        let size: Int                = Int(view.frame.size.width*1/3)
        animationView.frame          = CGRect(x: (Int(view.frame.width)-size)/2, y: (Int(view.frame.height)-size)*2/5, width: size, height: size)
        animationView.animation      = Animation.named("loading")
        animationView.contentMode    = .scaleAspectFit
        animationView.animationSpeed = 0.5
        animationView.loopMode       = .loop
        animationView.play()
        view.addSubview(animationView)
    }
    
    
    // Mail Authentication Check
    func checkAuthenticateMail() {
        // No authenticated user
        if Auth.auth().currentUser == nil {
            self.animationView.removeFromSuperview()
            return
        }
        
        // Fill user information
        emailTextField.text    = UserDefaults.standard.object(forKey: "email")    as! String
        passwordTextField.text = UserDefaults.standard.object(forKey: "password") as! String
        
        // Update user authentication
        Auth.auth().currentUser?.reload(completion: {(error) in
            if error != nil {return}
            
            if Auth.auth().currentUser?.isEmailVerified == true {
                self.transition()
                return
            }
            
            if Auth.auth().currentUser?.isEmailVerified == false {
                let alert = self.alertModel.noResultsAlert(title: "????????????", message: "?????????????????????????????????????????????\n???????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
                self.animationView.removeFromSuperview()
                return
            }
        })
    }
    
    // MARK:- UI Generator
    
    // Label
    func createLabel() {
        titleLabel.frame         = CGRect(x: 0, y: view.frame.height*2/10, width: view.frame.width, height: 40)
        titleLabel.font          = UIFont(name: "AvenirNext-Heavy",size: CGFloat(40))
        titleLabel.textColor     = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.text          = "Gourmet Mapp"
        view.addSubview(titleLabel)
    }
    
    // TextField
    func createTextField(textField: UITextField, hintText: String, x: CGFloat, y: CGFloat) {
        textField.frame          = CGRect(x: x, y: y, width: view.frame.width*8/10, height: 20)
        textField.font           = UIFont(name: "AvenirNext-Heavy",size: CGFloat(15))
        textField.textColor      = .darkGray
        textField.textAlignment  = .center
        textField.placeholder    = hintText
        textField.delegate       = self
        if hintText == "Password" {textField.isSecureTextEntry = true}
        textField.addBorderBottom(height: 1.0, color: .lightGray)
        view.addSubview(textField)
    }
    
    // Button
    func createButton(button: UIButton, caption: String, x: CGFloat, y: CGFloat, selector: Selector) {
        button.frame             = CGRect(x: x, y: y, width: view.frame.width*3/10, height: 20)
        button.titleLabel?.font  = UIFont(name: "AvenirNext-Heavy",size: CGFloat(15))
        button.setTitleColor(UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1), for: .normal)
        button.setTitle(caption, for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: selector, for: .touchUpInside)
    }
    
    
    // MARK:- UI actions
    
    @objc func signIn(_ sender: UIButton) {
        if self.textFieldValidationBlank() {return}
        self.startAnimating()
        
        // Mail authentication
        if let email = emailTextField.text, let password = passwordTextField.text {
            UserDefaults.standard.setValue(self.emailTextField.text, forKey: "email")
            UserDefaults.standard.setValue(self.passwordTextField.text, forKey: "password")
            
            // Create user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.logInError(error: error as! NSError)
                    return
                }
                // Send mail for authentication
                result!.user.sendEmailVerification(completion: { (error) in
                    let alert = self.alertModel.noResultsAlert(title: "?????????", message: "???????????????????????????????????????\n???????????????????????????????????????")
                    self.present(alert, animated: true, completion: nil)
                    self.animationView.removeFromSuperview()
                })
            }
        }
    }
    
    
    @objc func logIn(_ sender: UIButton) {
        if self.textFieldValidationBlank() {return}
        self.startAnimating()
        
        // Do nothing if no authentication
        if Auth.auth().currentUser?.isEmailVerified == false {
            let alert = self.alertModel.noResultsAlert(title: "????????????", message: "???????????????????????????????????????\n???????????????????????????????????????")
            self.present(alert, animated: true, completion: nil)
            self.animationView.removeFromSuperview()
            return
        }
        
        // Login
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.logInError(error: error as! NSError)
                    return
                }
                self.transition()
            }
        }
    }

    
    // View Transition
    func transition() {
        let mainVC = self.storyboard?.instantiateViewController(identifier: "mainVC") as! MainViewController
        self.navigationController?.pushViewController(mainVC, animated: true)
        self.animationView.removeFromSuperview()
    }
    
    
    // textfield validation
    func textFieldValidationBlank() -> Bool {
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alert = self.alertModel.noResultsAlert(title: "?????????", message: "??????????????????????????????????????????????????????????????????")
            self.present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }

    
    // FirebaseAuth Error
    func logInError(error: NSError) {
        if error == nil {return}
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .invalidEmail:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "???????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
            case .emailAlreadyInUse:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "????????????????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
            case .weakPassword:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "??????????????????6?????????????????????")
                self.present(alert, animated: true, completion: nil)
            case .operationNotAllowed:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "???????????????????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
            case .userDisabled:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "?????????????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
            default:
                let alert = self.alertModel.noResultsAlert(title: "?????????", message: "????????????????????????????????????????????????")
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.animationView.removeFromSuperview()
    }
}


// MARK:- Extension

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
