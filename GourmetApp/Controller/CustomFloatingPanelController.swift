
import Foundation
import FloatingPanel

class CustomFloatingPanelController: FloatingPanelLayout {
    
    // Floating position
    let position    : FloatingPanelPosition  = .bottom
    var initialState: FloatingPanelState     = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(fractionalInset: 0.40, edge: .top,    referenceGuide: .superview),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.22, edge: .bottom, referenceGuide: .superview),
            .tip:  FloatingPanelLayoutAnchor(fractionalInset: 0.05, edge: .bottom, referenceGuide: .superview)
        ]
    }
    
    // Size of right and left
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ]
    }
}
