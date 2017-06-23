//
//  CloudKitManager.swift
//  Period Flow 2
//
//  Created by Antonija on 23/06/2017.
//  Copyright © 2017 Antonija. All rights reserved.
//

import Foundation
import CloudKit
import PromiseKit
import SwiftDate

class CloudManager {

    static var instance = CloudManager()
    fileprivate init() {}
    
    // MARK: - Properties
    
    var periods: [Period] = []
    let container = CKContainer.default()
    let database = CKContainer.default().privateCloudDatabase
    
    // MARK: - Methods
    
    /// Save new Period
    func savePeriod(period: Period) {
        let record = CKRecord(recordType: "Period")
        
        let dates = period.dates as CKRecordValue
        let startDate = period.startDate as CKRecordValue
        let endDate = period.endDate as CKRecordValue
        
        record.setObject(dates, forKey: "dates")
        record.setObject(startDate, forKey: "startDate")
        record.setObject(endDate, forKey: "endDate")
        
        database.save(record) { record, error in
            if error != nil {
                print("Error: \(error.debugDescription)")
            } else {
                print("Record saved!")
            }
        }
    }
    
    /// Fetch all periods
    func fetchAllPeriods() -> Promise<[Period]> {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Period", predicate: predicate)
        
        return Promise { fulfill, reject in
            database.perform(query, inZoneWith: nil) { records, error in
                if error != nil {
                    guard let error = error else { return }
                    reject(error)
                } else {
                    guard let records = records else { return }
                    for record in records {
                        let startDate = record.object(forKey: "startDate") as! Date
                        let endDate = record.object(forKey: "endDate") as! Date
                        let dates = record.object(forKey: "dates") as! [Date]
                        let newPeriod = Period(dates: dates, startDate: startDate, endDate: endDate)
                        self.periods.append(newPeriod)
                    }
                    print("Download complete. ✅")
                    fulfill(self.periods)
                }
            }
        }
        
    }
    
    /// Determine if you need to start new Period or append date to existing
    func determineWhatToDoWithDate(date: Date) {
        print("Date to handle \(date.string())")
        if matchedPeriod(date: date) != nil {
            print("Updating existing period")
            // FIXME: - Update period
        } else {
            print("Creating new period")
            CloudManager.instance.savePeriod(period: Period(date: date))
        }
    }
    
    func matchedPeriod(date: Date) -> Period? {
        var matchedPeriod: Period?
        
        for period in periods {
            let dateFromStartDate = period.startDate - 8.days
            let dateFromEndDate = period.endDate + 8.days
            if date.isBetweeen(date: dateFromStartDate, andDate: dateFromEndDate) {
                print("I belong to \(period.dates)")
                matchedPeriod = period
            }
        }
    
        return matchedPeriod
    }
    
}


extension Date {
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}
