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
        database.save(createCKRecord(period: period)) { record, error in
            if error != nil {
                print("Error: \(error.debugDescription)")
            } else {
                print("Record saved!")
            }
        }
    }
    
    /// Creates CKRecord from Period
    func createCKRecord(period: Period) -> CKRecord {
        let record = CKRecord(recordType: "Period")
        
        let startDate = period.startDate as CKRecordValue
        let endDate = period.endDate as CKRecordValue
        
        record.setObject(startDate, forKey: "startDate")
        record.setObject(endDate, forKey: "endDate")
        
        return record
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
                        let recordID = record.object(forKey: "recordID") as! CKRecordID
                        
                        let newPeriod = Period(startDate: startDate, endDate: endDate, recordID: recordID)
                        self.periods.append(newPeriod)
                    }
                    print("Download complete. ✅")
                    fulfill(self.periods)
                }
            }
        }
        
    }
    
    func getDaysUntilNextPeriod() -> Int? {
        let today = Date()
        guard let lastPeriod = getLastPeriod() else { return nil }
        let days = lastPeriod.predictionDate?.interval(ofComponent: .day, fromDate: today)
        return days
    }
    
    /// Get last Period
    func getLastPeriod() -> Period? {
        // Delete period that has date
        if periods.isEmpty {
            return nil
        } else {
            let sortedPeriods = periods.sorted { $0.startDate.compare($1.startDate) == .orderedAscending }
            return sortedPeriods.last!
        }
    }
    
    func getPeriodInRangeForSelection(date: Date) -> Period? {
        var periodInRange: Period?
        
        for period in periods {
            let dateFromStartDate = period.startDate - 8.days
            let dateFromEndDate = period.endDate + 8.days
            if date.isBetweeen(date: dateFromStartDate, andDate: dateFromEndDate) {
                periodInRange = period
                break
            }
        }
        
        return periodInRange
    }
    
    func getPeriodInRangeForDeselection(date: Date) -> Period {
        var periodInRange: Period?
        
        for period in periods {
            if period.assumedDates.contains(date) {
                periodInRange = period
                break
            }
        }
        
        // FIXME: - See how to unwrap this optional
        return periodInRange!
    }
    
    /// Updates or starts a new Period
    func updateOrStartNew(date: Date) {
        
            print("Will update or start new ✅")
            // If there is no period, start new
            guard let period = getPeriodInRangeForSelection(date: date) else {
                savePeriod(period: Period(date: date))
                periods.append(Period(date: date))
                return
            }
            
            // Modify temporary period
            if date.isAfter(date: period.endDate, granularity: .day) {
                print("Taped date is AFTER endDate and will be new endDate")
                period.endDate = date
            } else if date.isBefore(date: period.startDate, granularity: .day) {
                period.startDate = date
            } else {
                print("WTF this is wrong!")
            }
            
            
            // Modify real period in array
            for var oldPeriod in periods {
                if oldPeriod.recordID == period.recordID {
                    oldPeriod = period
                }
            }
            
            // Update in iCloud
            self.updatePeriodInCloud(period: period)
        
    }
    
    /// Updates or deletes existing Period
    func updatePeriodOrDelete(date: Date) {

            print("Will update or Delete 🛑")
            let period = getPeriodInRangeForDeselection(date: date)
            
            // Modify temporary period
            let daysToStart = abs(period.startDate.interval(ofComponent: .day, fromDate: date))
            let daysToEnd = abs(period.endDate.interval(ofComponent: .day, fromDate: date))
            print("Date tapped: \(date.string(custom: "dd.MM.")), to start has: \(daysToStart), to end has; \(daysToEnd)")
            
            if daysToStart == 0 && daysToEnd == 0 {
                // Delete period that has date
                if let index = periods.index(where: { $0.assumedDates.first == date }) {
                    periods.remove(at: index)
                }
                
                // Delete motherfucker from iCloud
                guard let recordID = period.recordID else { return }
                database.delete(withRecordID: recordID, completionHandler: { _, error in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    } else {
                        print("Period deleted from cloud")
                    }
                })
            } else if daysToStart == 0 {
                period.startDate = date + 1.day
            } else if daysToEnd == 0 {
                period.endDate = date - 1.day
            } else {
                if daysToStart > daysToEnd {
                    print("Modifying end")
                    period.endDate = date
                } else if daysToStart == daysToEnd {
                    print("Modifying start because fuck you")
                    period.startDate = date
                } else {
                    print("Modifying start")
                    period.startDate = date
                }
                
                // Modify real period in array
                for var oldPeriod in periods {
                    if oldPeriod.recordID == period.recordID {
                        oldPeriod = period
                    }
                }
                
                // Update in iCloud
                updatePeriodInCloud(period: period)
            }
        
    }

    func updatePeriodInCloud(period: Period) {
        guard let recordID = period.recordID else { return }
        
        database.fetch(withRecordID: recordID, completionHandler: { record , error in
            
            guard let record = record else {
                // handle errors here
                return
            }
            
            record["startDate"] = period.startDate as CKRecordValue
            record["endDate"] = period.endDate as CKRecordValue
            
            self.database.save(record) { record, savedError in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }
            
        })
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
