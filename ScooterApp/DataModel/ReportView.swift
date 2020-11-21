//
//  ReportView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 15/11/2020.
//

import SwiftUI

struct ReportView: View {
    @EnvironmentObject var report: Report
    @State var showAlert = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            
            //            Section (header: Text("Progress")) {
            //                ProgressView(value: 0.8)
            //            }
            Section (header: SectionHeaderText(text: "Take a photo", done: report.hasPhoto(), suffix: "(Required)")) {
                GeometryReader(content: { geometry in
                    GetPhotoView(photo: $report.photo).frame(width: geometry.size.width, height: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .listRowInsets(EdgeInsets())
            }
            
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
            
            Section (header: Text("Type of violation")) {
                Toggle("Is Misplaced", isOn: $report.misplaced)
                Toggle("Is Laying", isOn: $report.laying)
                Toggle("Is Broken", isOn: $report.broken)
                Toggle("Other", isOn: $report.other)
            }
            
            Section (header: Text("Comment")) {
                TextField("Enter a comment", text: $report.comment)
            }
            
            Section {
                Button("Submit", action: {//print("SUBMIT PRESSED")
                    ReportStore.shared.addReport(report: report)
                    self.showAlert = true
                    self.mode.wrappedValue.dismiss()
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
            Label(text, systemImage: "checkmark.circle.fill").foregroundColor(.green)
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
            ReportView().environmentObject(Report())
        }).navigationBarTitle("Map", displayMode: .large)
    }
}
