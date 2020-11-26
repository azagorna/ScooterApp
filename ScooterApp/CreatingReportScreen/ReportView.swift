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
    @State var showQRSheet = false
    @State var qrCode = ""
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    func submitNoPhotoText() -> String {
        report.hasPhoto() ? "" : "\nTake a photo\n"
    }
    
    func submitNoViolationText() -> String {
        report.hasViolation() ? "" : "\nChoose the type of violation\n"
    }
    
    var body: some View {
        Form {
            Section (header: SectionHeaderText(text: "Take a photo", done: report.photo != nil, suffix: "(Required)")) {
                GeometryReader(content: { geometry in
                    GetPhotoView(photo: $report.photo).ignoresSafeArea().onDisappear(perform: {
                        if report.photo != nil {
                            report.setTimestamp()
                            report.setLocation()
                        }
                    })
                    .frame(width: geometry.size.width, height: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .listRowInsets(EdgeInsets())
            }
            Text("Date: \(report.timestamp?.description ?? "No date set yet")")
            Text("Latitude: \(report.latitude ?? 0.0)")
            Text("Longitude: \(report.longitude ?? 0.0)")
            Text("QR code: \(report.getQRcodeAsString())")
            Text("Brand: \(report.getBrandAsString())")
            
            Section (header: SectionHeaderText(text: "Scan QR Code", done: report.hasQRcode(), suffix: "(Optional)")
            ) {
                Group {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Divider()
                        Text("Brand of the scooter: \(report.brand.rawValue)")
                    }
                }
                .sheet(isPresented: $showQRSheet) {
                    ScannerView(qrCode: $qrCode, isPresented: $showQRSheet)
                        .onDisappear(perform: {
                            print("Got qrCode:", qrCode)
                            if !qrCode.isEmpty {
                                report.setQRCode(qrCode)
                            }
                        })
                }
            }
            .onTapGesture {
                showQRSheet = true
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
                
                // Custom solution with "DONE" button:
                DoneTextField(placeholder: "Enter a comment", text: $report.comment, isfocusAble: false)
                
            }
            
            Section(header: Text("Send Report")) {
                Button("Submit", action: {
                    if report.checkIfSubmittable() {
                        ReportStore.singleton.uploadPhoto(image: report.photo!, name: report.photoFilename)
                        ReportStore.singleton.uploadReport(report: report)
                        //ReportStore.singleton.addReport(report: report)
                        self.mode.wrappedValue.dismiss()
                    }
                    self.showAlert = true
                })
                .alert(isPresented: $showAlert) {
                    if report.checkIfSubmittable() {
                        return Alert(
                            title: Text("Thank you!"),
                            message: Text("Your reports help us improve!")
                        )} else {
                            return Alert(
                                title: Text("Missing information"),
                                message: Text("\(submitNoPhotoText())\(submitNoViolationText())")
                            )
                        }
                }
            }
        }
        .navigationBarTitle("Report")
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
            ReportView(report: Report())
        }).navigationBarTitle("Map", displayMode: .large)
    }
}
