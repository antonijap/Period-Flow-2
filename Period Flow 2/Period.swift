//
//  Period.swift
//  Period Flow 2
//
//  Created by Antonija on 11/06/2017.
//  Copyright © 2017 Antonija Pek. All rights reserved.
//

import Foundation
import SwiftDate
import CloudKit

class Period {
    
    // FIXME: - When
    
    // MARK: - Properties
    var startDate: Date
    var endDate: Date
    var recordID: CKRecordID?
    
    var predictionDate: Date? {
        let cycleDays = 28
        let futureDate = startDate + (cycleDays.days - 1.days)
        return futureDate
    }
    
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
        
        dates.sort(by: { $0.compare($1) == .orderedAscending })
        return dates
    }
    
    init(date: Date) {
        startDate = date
        endDate = date
    }
    
    convenience init(startDate: Date, endDate: Date, recordID: CKRecordID) {
        self.init(date: startDate)
        self.endDate = endDate
        self.recordID = recordID
    }
}
