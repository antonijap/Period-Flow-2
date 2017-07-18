//
//  PredictionCellView.swift
//  Period Flow 2
//
//  Created by Antonija on 24/06/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import UIKit

class PredictionCellView: UIView {
    override func awakeFromNib() {
        self.layer.borderColor = Color.primary.cgColor
        self.layer.borderWidth = 2
        self.clipsToBounds = false
        self.layer.cornerRadius = self.bounds.width / 2
        self.layoutIfNeeded()
    }
}
