//
//  File.swift
//
//
//  Created by Max Tymchii on 12.11.2023.
//

import Foundation
import UIKit

private var counterViewKey: UInt8 = 0
private var titleViewKey: UInt8 = 1
private var containerViewKey: UInt8 = 2
private var backgroundBlureViewKey: UInt8 = 3

public extension UIViewController {
    var backgroundBlureView: VisualEffectView? {
        get {
            return objc_getAssociatedObject(self, &backgroundBlureViewKey) as? VisualEffectView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &backgroundBlureViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    var counterView: CounterView? {
        get {
            return objc_getAssociatedObject(self, &counterViewKey) as? CounterView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &counterViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var titleLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &titleViewKey) as? UILabel
        }
        set(newValue) {
            objc_setAssociatedObject(self, &titleViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var containerView: UIView? {
        get {
            return objc_getAssociatedObject(self, &containerViewKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &containerViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setupBlurView() {
        guard let navigationBar = navigationController?.navigationBar.subviews[0] else {
            return
        }
        
        if (navigationController?.navigationBar.subviews[0].subviews.count)! > 1 {
            return
        }
        let _backgroundBlureView = VisualEffectView()
        _backgroundBlureView.colorTint = ColorTheme.live().surface_4.uiColor
        _backgroundBlureView.colorTintAlpha = 0.2
        _backgroundBlureView.blurRadius = 16
        _backgroundBlureView.scale = 1
        
        backgroundBlureView = _backgroundBlureView
        _backgroundBlureView.translatesAutoresizingMaskIntoConstraints = false
        _backgroundBlureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _backgroundBlureView.frame = navigationBar.bounds
//        navigationBar.addSubview(_backgroundBlureView)
        navigationBar.insertSubview(_backgroundBlureView, at: 0)
        _backgroundBlureView.layoutIfNeeded()
       
        navigationBar.subviews.forEach {
            if $0 is VisualEffectView {
                
            } else {
                $0.isHidden = true
            }
        }

    }

    func setupCustomBigTitleRepresentation(counter: CounterView.Counter) {
        guard let bigTitleLabel = findBigTitleLabel(),
              let bigLabelSuperview = bigTitleLabel.superview,
              counterView == nil,
              containerView == nil,
              titleLabel == nil else {
            return
        }

        let _containerView = createContainerView()
        containerView = _containerView
        bigTitleLabel.addSubview(_containerView)
        configureContainerViewLayout(_containerView, bigTitleLabel, bigLabelSuperview)

        let _counterView = createCounterView(counter: counter)
        counterView = _counterView

        let _bigNavigationBarTitleLabel = createBigNavigationBarTitleLabel(from: bigTitleLabel)
        titleLabel = _bigNavigationBarTitleLabel
        _containerView.addSubview(_bigNavigationBarTitleLabel)
        _containerView.addSubview(_counterView)
        configureSubViewLayouts(_bigNavigationBarTitleLabel, _counterView, _containerView)

        _containerView.layoutIfNeeded()
    }

    // Helper functions

    func findBigTitleLabel() -> UILabel? {
        return navigationController?
            .navigationBar
            .subviews[1]
            .subviews[0] as? UILabel
    }

    func createContainerView() -> UIView {
        let _containerView = UIView()
        _containerView.backgroundColor = .clear//ColorTheme.live().surface_1.uiColor
        return _containerView
    }

    func configureContainerViewLayout(_ containerView: UIView, _ bigTitleLabel: UILabel, _ bigLabelSuperview: UIView) {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        containerView.leadingAnchor.constraint(equalTo: bigTitleLabel.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: bigLabelSuperview.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bigTitleLabel.bottomAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: bigTitleLabel.topAnchor).isActive = true
    }

    func createCounterView(counter: CounterView.Counter) -> CounterView {
        return CounterView(counter: counter)
    }

    func createBigNavigationBarTitleLabel(from bigTitleLabel: UILabel) -> UILabel {
        let _bigNavigationBarTitleLabel = UILabel()
        _bigNavigationBarTitleLabel.attributedText = bigTitleLabel.attributedText
        _bigNavigationBarTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return _bigNavigationBarTitleLabel
    }

    func configureSubViewLayouts(_ bigNavigationBarTitleLabel: UILabel, _ counterView: CounterView, _ containerView: UIView) {
        bigNavigationBarTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bigNavigationBarTitleLabel.heightAnchor.constraint(equalTo: bigNavigationBarTitleLabel.heightAnchor).isActive = true
        counterView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        counterView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        bigNavigationBarTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: counterView.leadingAnchor).isActive = true
    }

}
