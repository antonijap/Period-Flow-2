//
//  CellView.swift
//  Period Flow 2
//
//  Created by Antonija on 10/06/2017.
//  Copyright © 2017 Antonija Pek. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class CellView: JTAppleCell {
    
    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var selectedView: UIView!
    
    // MARK: - Properties
    
    // MARK: - Methods
    
    /// This is called whenever cell is render to the screen
    func setupCellBeforeDisplay(_ cellState: CellState, date: Date) {
        dateLabel.text = cellState.date.string(custom: "d")
//        configureTextColor(state: cellState)
//        configureBackgroundColor(state: cellState)
//        configureTodayView(date: date)
        if cellState.isSelected {
            selectedBackgroundView?.isHidden = false
            selectedBackgroundView?.backgroundColor = UIColor.cyan
            dateLabel.textColor = UIColor.white
        } else {
            selectedBackgroundView?.isHidden = true
            dateLabel.textColor = UIColor.black
        }
    }
    
    func configureTodayView(date: Date) {
        if date.isToday {
            displayToday()
        } else {
            todayView.isHidden = true
        }
    }
    
    func configureTextColor(state: CellState) {
        if state.isSelected {
            dateLabel.textColor = UIColor.white
        } else {
            dateLabel.textColor = UIColor.black
        }
    }
    
    func configureBackgroundColor(state: CellState) {
        if state.isSelected {
            middleSelectedView()
        } else {
            defaultView()
        }
    }
    
    func selectionChanged(state: CellState) {
        configureTextColor(state: state)
        configureBackgroundColor(state: state)
    }
    
    func defaultView() {
        selectedView.isHidden = true
        todayView.isHidden = true
    }
    
    func leftSelectedView() {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft], radius: self.bounds.height / 2)
    }
    
    func middleSelectedView() {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft, .bottomRight, .topRight], radius: 0)
    }
    
    func rightSelectedView() {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomRight, .topRight], radius: self.bounds.height / 2)
    }
    
    func roundedSelectedView() {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft, .bottomRight, .topRight], radius: self.bounds.height / 2)
    }
    
    func displayToday() {
        todayView.isHidden = false
        todayView.roundCorners([.bottomLeft, .topLeft, .bottomRight, .topRight], radius: self.bounds.height / 2)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class View: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners([.topLeft, .bottomLeft], radius: 10)
    }
}
