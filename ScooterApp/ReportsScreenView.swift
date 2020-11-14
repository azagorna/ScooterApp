//
//  UserReportsView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import SwiftUI

struct ReportsScreenView: View {

    let reports = ["Report1", "Report2", "Report3", "..."]

    var body: some View {
            List(reports, id: \.self) { report in
                Label(report, systemImage: "photo")
            }.navigationBarTitle("My Reports", displayMode: .inline)
    }
}

struct ReportsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsScreenView()
    }
}
