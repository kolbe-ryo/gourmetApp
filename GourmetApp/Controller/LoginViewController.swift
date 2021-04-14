
import UIKit
import Lottie
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    // MARK:- UI Variant
    private let titleLabel        = UILabel()
    private let emailTextField    = UITextField()
    private let passwordTextField = UITextField()
    private let signInButton      = UIButton()
    private let logInButton       = UIButton()
    @IBOutlet weak var backgoundImage: UIImageView!
    
    // Class
    let alertModel    = AlertModel()
    let imageModel    = ImageModel()
    var animationView = AnimationView()
    
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if Auth.auth().currentUser == nil {
            self.animationView.removeFromSuperview()
            return
        }
        emailTextField.text    = UserDefaults.standard.object(forKey: "email")    as! String
        passwordTextField.text = UserDefaults.standard.object(forKey: "password") as! String
        
        // 認証状態の更新
        Auth.auth().currentUser?.reload(completion: {(error) in
            if error != nil {return}
            // メール認証が完了しているか確認
            if Auth.auth().currentUser?.isEmailVerified == true {
                self.transition()
            // メール認証が未完了
            } else if Auth.auth().currentUser?.isEmailVerified == false {
                let alert = self.alertModel.noResultsAlert(title: "確認事項", message: "メールを確認し、承認を完了後に\nアプリを再起動して下さい。")
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
        self.startAnimating()
        // メール認証を行う
        if let email = emailTextField.text, let password = passwordTextField.text {
            UserDefaults.standard.setValue(self.emailTextField.text, forKey: "email")
            UserDefaults.standard.setValue(self.passwordTextField.text, forKey: "password")
            // メールによるユーザー作成
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    self.logInError(error: error as! NSError)
                    return
                }
                // 認証用メールを送信
                result!.user.sendEmailVerification(completion: { (error) in
                    let alert = self.alertModel.noResultsAlert(title: "仮登録", message: "認証メールを送信しました。\n確認し認証を進めて下さい。")
                    self.present(alert, animated: true, completion: nil)
                    self.animationView.removeFromSuperview()
                })
            }
        }
    }
    
    
    @objc func logIn(_ sender: UIButton) {
        self.startAnimating()
        // メール認証が終了していない場合、何もしない
        if Auth.auth().currentUser?.isEmailVerified == false {
            let alert = self.alertModel.noResultsAlert(title: "ログイン", message: "認証メールを送信しました。\n確認し認証を進めて下さい。")
            self.present(alert, animated: true, completion: nil)
            self.animationView.removeFromSuperview()
            return
        }
        // ログイン処理
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

    
    // FirebaseAuth Error
    func logInError(error: NSError) {
        if error == nil {return}
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .invalidEmail:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "メールの形式が異なります。")
                self.present(alert, animated: true, completion: nil)
            case .emailAlreadyInUse:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "すでに使用されているメールです。")
                self.present(alert, animated: true, completion: nil)
            case .weakPassword:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "パスワードは6文字以上です。")
                self.present(alert, animated: true, completion: nil)
            case .operationNotAllowed:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "アカウントが有効になっていません。")
                self.present(alert, animated: true, completion: nil)
            case .userDisabled:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "ユーザーが無効になっています。")
                self.present(alert, animated: true, completion: nil)
            default:
                let alert = self.alertModel.noResultsAlert(title: "エラー", message: "通信状態が悪い可能性があります。")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


// MARK:- Extension

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
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
