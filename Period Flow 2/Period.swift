//
//  Period.swift
//  Period Flow 2
//
//  Created by Antonija on 11/06/2017.
//  Copyright © 2017 Antonija Pek. All rights reserved.
//

import Foundation
import SwiftDate

class Period {
    
    // MARK: - Properties
    var dates: [Date] = []
    var startDate: Date
    var endDate: Date
    
    var predictionDate: Date? {
        let cycleDays = 28
        let futureDate = startDate + (cycleDays.days - 1.days)
        return futureDate
    }
    
    /// Populates an array of dates in between start and end date of object
    var assumedDates: [Date] {
        
        var dates = [Date]()
        
        if startDate == endDate {
            dates.append(startDate)
        } else {
            var nextDate = startDate
            dates.append(startDate)
            repeat {
                nextDate = nextDate + 1.days
                dates.append(nextDate)
            } while nextDate < endDate
        }
        
        return dates
    }
    
    init(date: Date) {
        dates.append(date)
        startDate = date
        endDate = date
    }
    
    convenience init(dates: [Date], startDate: Date, endDate: Date) {
        self.init(date: startDate)
        self.dates = (dates)
        self.endDate = endDate
    }
}
