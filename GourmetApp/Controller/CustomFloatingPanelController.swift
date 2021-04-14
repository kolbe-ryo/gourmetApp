//
//  CustomFloatingPanelController.swift
//  GourmetApp
//
//  Created by Ryo Fukahori on 2021/02/13.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelController: FloatingPanelLayout {
    
    // Floatingポジション
    let position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(fractionalInset: 0.4, edge: .top, referenceGuide: .superview),
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.22, edge: .bottom, referenceGuide: .superview),
            .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.05, edge: .bottom, referenceGuide: .superview)
        ]
    }
    
    // 左右のサイズ
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            surfaceView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ]
    }
    
}
