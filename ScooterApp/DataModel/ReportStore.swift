//
//  ReportStore.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import Foundation

class ReportStore{
    
    static let shared = ReportStore()

    //testing version - to be deleted
    var report1: Report = Report()
    var report2: Report = Report()
    var reports = [Report]()
    init() {
        report1.setTimestamp()
        try? report1.setLocation()
        report1.broken = true
        report1.photo = nil
        report2.setTimestamp()
        try? report2.setLocation()
        report2.misplaced = true
        report2.photo = nil
        reports.append(report1)
        reports.append(report2)
    }




    //final version
    //var reports = [Report]()

    func addReport(report: Report) {
        reports.append(report)
    }

}

