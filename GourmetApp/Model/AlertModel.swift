
import UIKit
import Foundation
import FloatingPanel

protocol AlertDelegate {
    func alertDelegate(str: String)
}

class AlertModel: FloatingPanelControllerDelegate {
    var alertDelegate: AlertDelegate?

    // ログイン時のアラート
    func noResultsAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    // お気に入り追加時のアラート
    func addFavoriteAlert(title: String, message: String, VC: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        // Wantリストへ保存
        alert.addAction(UIAlertAction(title: "Want", style: .default, handler: { (alert) in
            self.alertDelegate?.alertDelegate(str: alert.title!)
        }))
        
        // Wentリストへ保存
        alert.addAction(UIAlertAction(title: "Good", style: .default, handler: { (alert) in
            self.alertDelegate?.alertDelegate(str: alert.title!)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }

    
    func addImageAlert(title: String, message: String, VC: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert) in
            self.alertDelegate?.alertDelegate(str: "Camera")
        }))
        
        alert.addAction(UIAlertAction(title: "Album", style: .default, handler: { (alert) in
            self.alertDelegate?.alertDelegate(str: "Album")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
    
    func checkDelete(title: String, message: String, VC: UIViewController) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            self.alertDelegate?.alertDelegate(str: "")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
}
