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
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var weekDaysStack: UIStackView!
    
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
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
        calendarView.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareLoading(opacity: 0.1)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        activityIndicator.color = UIColor.white
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        CloudManager.instance.fetchAllPeriods().then { periods -> Void in
            periods.forEach({ period in
                self.datesToSelect += period.assumedDates
            })
            self.prepareLoading(opacity: 1)
            activityIndicator.stopAnimating()
            self.configureInfoLabel()
            self.view.layer.opacity = 1.0
            self.calendarView.selectDates(self.datesToSelect, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            
            }.catch { error in
                print(error)
        }
    }
    
    // MARK: - Methods
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func prepareLoading(opacity: Float) {
        calendarView.layer.opacity = opacity
        monthNameLabel.layer.opacity = opacity
        yearLabel.layer.opacity = opacity
        infoLabel.layer.opacity = opacity
        weekDaysStack.layer.opacity = opacity
    }
    
    func configureInfoLabel() {
        guard let days = CloudManager.instance.getDaysUntilNextPeriod() else {
            infoLabel.text = "Tap to start"
            return
        }
        
        if days < 0 {
            infoLabel.text = "Period late \(abs(days)) days"
        } else if days == 0 {
            infoLabel.text = "Period starts today"
        } else {
            infoLabel.text = "Period in \(days) days"
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if cellState.dateBelongsTo == .followingMonthWithinBoundary || cellState.dateBelongsTo == .previousMonthWithinBoundary {
            calendarView.scrollToDate(date)
        }
        
        let cell = cell as! CellView
        CloudManager.instance.updateOrStartNew(date: date)
        cell.selectionChanged(state: cellState, date: date)
        calendarView.reloadData()
        updateUIForSelection()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CellView
        CloudManager.instance.updatePeriodOrDelete(date: date)
        cell.selectionChanged(state: cellState, date: date)
        calendarView.reloadData()
        updateUIForDeselection()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let firstDateInMonth = visibleDates.monthDates.first
        if let date = firstDateInMonth {
            monthNameLabel.text = date.date.monthName
            yearLabel.text = String(describing: date.date.year)
        }
    }
    
    
    func updateUIForDeselection() {
        calendarView.deselectAllDates(triggerSelectionDelegate: false)
        datesToSelect.removeAll()
        
        for period in CloudManager.instance.periods {
            self.datesToSelect += period.assumedDates
        }
        
        calendarView.selectDates(self.datesToSelect, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
        calendarView.reloadData()
        configureInfoLabel()
    }
    
    func updateUIForSelection() {
        datesToSelect.removeAll()
        
        for period in CloudManager.instance.periods {
            self.datesToSelect += period.assumedDates
        }
        
        calendarView.selectDates(self.datesToSelect, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        calendarView.reloadData()
        configureInfoLabel()
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
