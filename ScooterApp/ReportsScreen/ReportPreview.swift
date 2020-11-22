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
            
            Section (header: Text("Photo")) {
                GeometryReader(content: { geometry in
                    Image(uiImage: photo)
                        .resizable()
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
            
            Section (header: Text("Type of violation")) {
                if report.misplaced {
                    Label("Misplaced", systemImage: "checkmark.circle.fill")
                }
                if report.laying {
                    Label("Is Laying", systemImage: "checkmark.circle.fill")
                }
                if report.broken {
                    Label("Is Broken", systemImage: "checkmark.circle.fill")
                }
                if report.other {
                    Label("Other", systemImage: "checkmark.circle.fill")
                }
            }
            if !report.comment.isEmpty {
                Section (header: Text("Comment")) {
                    Text(report.comment)
                }
            }
            
        }
        
    }
}

struct ReportPreview_Previews: PreviewProvider {
    static var previews: some View {
        ReportPreview(report: Report(), photo: UIImage(named: "placeholder_missing_scooter")!)
    }
}
