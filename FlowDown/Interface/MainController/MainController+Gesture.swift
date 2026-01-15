//
//  MainController+Gesture.swift
//  FlowDown
//
//  Created by 秋星桥 on 1/20/25.
//

import UIKit

extension MainController {
    @objc func handleSidebarEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard presentedViewController == nil else { return }
        guard isSidebarCollapsed else { return }
        #if targetEnvironment(macCatalyst)
            return
        #else
            let translation = gesture.translation(in: view)
            let offset = max(0, translation.x)
            switch gesture.state {
            case .began, .changed:
                updateLayoutGuide(withOffset: offset)
            case .ended, .cancelled, .failed:
                if offset > 100 {
                    view.doWithAnimation { self.isSidebarCollapsed = false }
                } else {
                    updateLayoutGuideToOriginalStatus()
                }
            default:
                break
            }
        #endif
    }

    func updateGestureStatus(withOffset offset: CGFloat) -> Bool {
        updateLayoutGuide(withOffset: offset)
        if isSidebarCollapsed {
            if offset > 100 {
                view.doWithAnimation { self.isSidebarCollapsed = false }
                return true
            }
        } else {
            if offset < -100 {
                view.doWithAnimation { self.isSidebarCollapsed = true }
                return true
            }
        }
        return false
    }

    func updateLayoutGuideToOriginalStatus() {
        updateLayoutGuide(withOffset: 0)
    }

    private func updateLayoutGuide(withOffset offset: CGFloat) {
        #if targetEnvironment(macCatalyst)
            return
        #else
            var offset = offset
            view.doWithAnimation { [self] in
                if isSidebarCollapsed {
                    gestureLayoutGuide.snp.updateConstraints { make in
                        make.width.equalTo(max(0, offset))
                    }
                } else {
                    if offset > 0 { offset *= 0.1 }
                    gestureLayoutGuide.snp.updateConstraints { make in
                        make.left.equalTo(sidebarLayoutView.snp.right).offset(offset)
                    }
                }
            }
        #endif
    }
}
