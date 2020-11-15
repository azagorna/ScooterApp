//
//  ReportView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 15/11/2020.
//

import SwiftUI

struct ReportView: View {
    @EnvironmentObject var report: Report
    
    var body: some View {
        Form {
            
//            Section (header: Text("Progress")) {
//                ProgressView(value: 0.8)
//            }
            
            Section (header: Text("Scooter Photo")) {
                
                NavigationLink(destination: CameraScreenView()) {
                    Rectangle().frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                }
                .isDetailLink(false)
                .navigationBarTitle("Report", displayMode: .large)
            }
            
            Section (header: Text("Scan QR code")) {
                Group {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Divider()
                        Text("\(report.brand.rawValue)")
                    }
                }
            }
            
            Section (header: Text("Violation")) {
                Toggle("Is Misplaced", isOn: $report.misplaced)
                Toggle("Is Laying", isOn: $report.laying)
                Toggle("Is Broken", isOn: $report.broken)
                Toggle("Other", isOn: $report.other)
            }
            
            Section (header: Text("Comment")) {
                TextField("Enter a comment", text: $report.comment)
            }
            
            Section {
                Button("Submit", action: {print("SUBMIT PRESSED")}).disabled(!report.checkIfSubmittable())
            }
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView(content: {
            ReportView().environmentObject(Report())
        }).navigationBarTitle("Map", displayMode: .large)
    }
}
