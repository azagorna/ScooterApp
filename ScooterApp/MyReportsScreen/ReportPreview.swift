//
//  ReportView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 15/11/2020.
//

import SwiftUI

struct ReportPreview: View {
    let report: Report
    let photo: UIImage
    
    var body: some View {
        Form {
            
            Section (header: Text("Photo"), footer: AddressTextView(report: report)) {
                GeometryReader(content: { geometry in
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(nil, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                .listRowInsets(EdgeInsets())
            }
            
            Section (header: Text("Scooter QR code")) {
                Group {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                        Divider()
                        Text("Scooter brand: \(report.brand.rawValue)")
                    }
                }
            }
            
            Section (header: Text("Type of violation")) {
                if report.misplaced {
                    ViolationLabel(text: "Misplaced")
                }
                if report.laying {
                    ViolationLabel(text: "Is Laying")
                }
                if report.broken {
                    ViolationLabel(text: "Is Broken")
                }
                if report.other {
                    ViolationLabel(text: "Other")
                }
            }
            Section (header: Text("Comment")) {
                if report.comment.isEmpty {
                    Text("No comment").italic()
                } else {
                    Text("\"\(report.comment)\"").italic()
                }
            }
            
            // DEBUGGING
//            Section(header: Text("DEBUGGING")) {
//                Text("Date: \(report.timestamp?.description ?? "No date set yet")")
//                Text("Latitude: \(report.latitude ?? 0.0)")
//                Text("Longitude: \(report.longitude ?? 0.0)")
//                Text("Address: \(report.getAddressAsString())")
//                Text("QR code: \(report.getQRcodeAsString())")
//                Text("Brand: \(report.getBrandAsString())")
//            }.foregroundColor(.green)
        }
    }
}

struct ViolationLabel: View {
    let text: String
    var body: some View {
        HStack{
            Text(text)
            Image(systemName: "checkmark")
            Spacer()
        }
    }
}

struct ReportPreview_Previews: PreviewProvider {
    static var previews: some View {
        ReportPreview(report: Report(), photo: UIImage(named: "placeholder_missing_scooter")!)
    }
}
