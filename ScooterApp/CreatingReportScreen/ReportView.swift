//
//  ReportView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 15/11/2020.
//

import SwiftUI

struct ReportView: View {
    @StateObject var report: Report
    @State var showAlert = false
    let readOnly: Bool

    var body: some View {
        Form {
            
            //            Section (header: Text("Progress")) {
            //                ProgressView(value: 0.8)
            //            }
            Section (header: SectionHeaderText(text: "Take a photo", done: report.photo != nil, suffix: "(Required)")) {
                GeometryReader(content: { geometry in
                    GetPhotoView(photo: $report.photo)
                        .frame(width: geometry.size.width, height: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .listRowInsets(EdgeInsets())
            }
            Text("Date: \(report.timestamp?.description ?? "No date set yet")")
            Text("Latitude: \(report.latitude ?? 0.0)")
            Text("Longitude: \(report.longitude ?? 0.0)")
            
            Section (header: SectionHeaderText(text: "Scan QR Code", done: report.hasQRcode(), suffix: "(Optional)")
                        ) {
                Group {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Divider()
                        Text("Brand of the scooter: \(report.brand.rawValue)")
                    }
                }
            }
            
            Section (header: SectionHeaderText(text: "Type of violation", done: report.misplaced || report.laying || report.broken || report.other, suffix: "(Required)")) {
                Toggle("Is Misplaced", isOn: $report.misplaced)
                Toggle("Is Laying", isOn: $report.laying)
                Toggle("Is Broken", isOn: $report.broken)
                Toggle("Other", isOn: $report.other)
            }
            
            Section (header: SectionHeaderText(text: "Comment", done: !report.comment.isEmpty, suffix: "(Optional)")) {
                // Old Solution without "DONE" button
                //TextField("Enter a comment", text: $report.comment)
                
                // Custom solution:
                DoneTextField(placeholder: "Enter a comment", text: $report.comment, isfocusAble: false)
            }
            
            Section {
                Button("Submit", action: {
                    ReportStore.singleton.uploadPhoto(image: report.photo!, name: report.photoFilename)
                    ReportStore.singleton.uploadReport(report: report)
                    //ReportStore.singleton.addReport(report: report)
                    self.showAlert = true
                })//.disabled(!report.checkIfSubmittable())
                .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Thank you!"),
                                message: Text("Your reports help us improve!")
                            )
                        }
            }
        }
        .navigationBarTitle("Report")
        //        .navigationBarItems(trailing:
        //                                Button("Submit", action: {print("SUBMIT PRESSED")}).disabled(!report.checkIfSubmittable())
        //        )
    }
}

struct SectionHeaderText: View {
    let text: String
    let done: Bool
    let suffix: String
    
    var body: some View {
        if done {
            Label("Done", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                .flipsForRightToLeftLayoutDirection(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        } else {
            HStack {
                Text(text)
                Spacer()
                Text(suffix).font(.caption2)
            }
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView(content: {
            ReportView(report: Report(), readOnly: false)
        }).navigationBarTitle("Map", displayMode: .large)
    }
}
