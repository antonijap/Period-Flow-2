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
    @IBOutlet weak var predictionView: PredictionCellView!
    
    // MARK: - Properties
    
    // MARK: - Methods
    
    /// This is called whenever cell is render to the screen
    func setupCellBeforeDisplay(_ cellState: CellState, date: Date) {
        dateLabel.text = cellState.date.string(custom: "d")
        configureTextColor(state: cellState)
        configureBackgroundColor(state: cellState)
        configureTodayView(state: cellState)
        configurePrediction(state: cellState)
    }
    
    func configureTodayView(state: CellState) {
        if state.date.isToday {
            displayToday(state: state)
        } else {
            todayView.isHidden = true
        }
    }
    
    func configureTextColor(state: CellState) {
        if state.dateBelongsTo == .followingMonthWithinBoundary || state.dateBelongsTo == .previousMonthWithinBoundary {
            if state.isSelected {
                dateLabel.textColor = Color.whiteWithOpacity
            } else {
                dateLabel.textColor = Color.whiteWithOpacity
            }
        } else {
            if state.isSelected {
                if state.date.isToday {
                    dateLabel.textColor = UIColor.white
                } else {
                    dateLabel.textColor = UIColor.white
                }
                
            } else {
                dateLabel.textColor = UIColor.white
            }
        }
        
        
    }
    
    func configureBackgroundColor(state: CellState) {
        if state.dateBelongsTo == .followingMonthWithinBoundary || state.dateBelongsTo == .previousMonthWithinBoundary {
            if state.isSelected {
                if state.selectedPosition() == .left {
                    leftSelectedView(opacity: 0.5)
                } else if state.selectedPosition() == .right {
                    rightSelectedView(opacity: 0.5)
                } else if state.selectedPosition() == .middle {
                    middleSelectedView(opacity: 0.5)
                } else {
                    roundedSelectedView(opacity: 0.5)
                }
            } else {
                defaultView()
            }
        } else {
            if state.isSelected {
                if state.selectedPosition() == .left {
                    leftSelectedView(opacity: 1.0)
                } else if state.selectedPosition() == .right {
                    rightSelectedView(opacity: 1.0)
                } else if state.selectedPosition() == .middle {
                    middleSelectedView(opacity: 1.0)
                } else {
                    roundedSelectedView(opacity: 1.0)
                }
            } else {
                defaultView()
            }
        }
    }
    
    func selectionChanged(state: CellState, date: Date) {
        configureTextColor(state: state)
        configureBackgroundColor(state: state)
        configurePrediction(state: state)
    }
    
    func defaultView() {
        selectedView.isHidden = true
        todayView.isHidden = true
    }
    
    func leftSelectedView(opacity: Float) {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft], radius: self.bounds.height / 2)
        selectedView.layer.opacity = opacity
    }
    
    func middleSelectedView(opacity: Float) {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft, .bottomRight, .topRight], radius: 0)
        selectedView.layer.opacity = opacity
    }
    
    func rightSelectedView(opacity: Float) {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomRight, .topRight], radius: self.bounds.height / 2)
        selectedView.layer.opacity = opacity
    }
    
    func roundedSelectedView(opacity: Float) {
        selectedView.isHidden = false
        selectedView.roundCorners([.bottomLeft, .topLeft, .bottomRight, .topRight], radius: self.bounds.height / 2)
        selectedView.layer.opacity = opacity
    }
    
    func displayToday(state: CellState) {
        if state.isSelected && state.date.isToday {
            todayView.isHidden = false
//            todayView.clipsToBounds = false
//            todayView.layer.cornerRadius = self.bounds.width / 2
//            todayView.layoutIfNeeded()
            todayView.backgroundColor = UIColor.clear
            dateLabel.textColor = Color.accent
//            todayView.layer.borderWidth = 2
//            todayView.layer.borderColor = Color.accent.cgColor
        } else {
            todayView.isHidden = false
            todayView.layer.cornerRadius = self.bounds.width / 2
        }
    }
    
    func configurePrediction(state: CellState) {
        if CloudManager.instance.periods.count != 0 {
            guard let period = CloudManager.instance.getLastPeriod() else { return }
            if (period.predictionDate?.isInSameDayOf(date: state.date))! {
                predictionView.isHidden = false
            } else {
                predictionView.isHidden = true
            }
        }
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


