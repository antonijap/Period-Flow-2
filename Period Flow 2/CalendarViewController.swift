//
//  ViewController.swift
//  Period Flow 2
//
//  Created by Antonija on 10/06/2017.
//  Copyright © 2017 Antonija Pek. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwiftDate

class CalendarViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthNameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    // MARK: - Properties
    
    var datesToSelect = [Date]()

    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.allowsDateCellStretching = true
        calendarView.scrollingMode = .stopAtEachSection
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        calendarView.scrollToDate(Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CloudManager.instance.fetchAllPeriods().then { periods -> Void in
            periods.forEach({ period in
                self.datesToSelect += period.dates
            })
            self.calendarView.selectDates(self.datesToSelect, triggerSelectionDelegate: false)
        }.then { () -> Void in
            print("Reloading data... ✅")
            self.calendarView.reloadData()
        }.catch { error in
            print(error)
        }
    }
    
    // MARK: - Methods
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CellView
        
        // Figure out if selected date is part of a period
        CloudManager.instance.determineWhatToDoWithDate(date: date)

//        updateUIForSelection()
        cell.selectionChanged(state: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        let cell = cell as! CellView
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let firstDateInMonth = visibleDates.monthDates.first
        if let date = firstDateInMonth {
            monthNameLabel.text = date.date.monthName
            yearLabel.text = String(describing: date.date.year)
        }
        
    }
    
    /// Update UI when a date is selected
    func updateUIForSelection() {
        var datesToSelect = [Date]()
        for period in CloudManager.instance.periods {
            datesToSelect += period.assumedDates.filter { date in
                calendarView.selectedDates.contains(date as Date) != true
            }
        }
        
        calendarView.selectDates(datesToSelect, triggerSelectionDelegate: false)
        calendarView.reloadData()
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2016 02 01")!
        let endDate = formatter.date(from: "2018 02 01")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "Cell", for: indexPath) as! CellView
        cell.setupCellBeforeDisplay(cellState, date: date)
        return cell
    }
}
