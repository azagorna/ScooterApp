//
//  ReportView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 15/11/2020.
//

import SwiftUI
import CodeScanner //Source: https://github.com/twostraws/CodeScanner (MIT License)

struct ReportView: View {
    @StateObject var report: Report
    @State var showQRSheet = false
    @State var qrCode = ""
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            Section (header: SectionHeaderText(text: "Take a photo", done: report.photo != nil, suffix: "(Required)"), footer: AddressTextView(report: report)) {
                GeometryReader(content: { geo in
                    GetPhotoView(photo: $report.photo).ignoresSafeArea().onDisappear(perform: {
                        if report.photo != nil {
                            report.photo = report.photo?.squareCropImage() // Crop Photo
                            report.photo = report.photo?.resizeImage(targetSize: CGSize(width: 512, height: 512)) // Scale Photo
                            report.setTimestamp()
                            report.setLocation()
                        }
                    })
                    .frame(width: geo.size.width, height: geo.size.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
                        switch report.brand {
                            case .none:
                                Text("Click to scan")
                            case .unknown:
                                Text("Found: \(report.getBrandAsString())")
                            default:
                                Text("Scooter brand: \(report.brand.rawValue)")
                        }
                        
                    }
                }
                .sheet(isPresented: $showQRSheet) {
                    
                    ZStack {
                        
                        // Scanner camera
                        CodeScannerView(codeTypes: [.qr], simulatedData: "https://lime.bike/bc/v1/PXGOKXY=") { result in
                            switch result {
                                case .success(let code):
                                    print("Found code: \(code)")
                                    self.report.setQRCode(code)
                                    self.showQRSheet = false
                                case .failure(let error):
                                    print(error.localizedDescription)
                            }
                        }
                        
                        // On top of scanner camera
                        GeometryReader(content: { geo in
                            VStack{
                                // Top black bar
                                ZStack {
                                    
                                    Rectangle()
                                        .fill(Color.black)
                                        .opacity(0.8)
                                    Label("Scan the scooter's QR code", systemImage: "barcode.viewfinder")
                                        .font(.headline)
                                        .padding(20)
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                    HStack {
                                        VStack {
                                            Button(action: {self.showQRSheet = false}, label: {
                                                Label("Cancel", systemImage: "chevron.left").font(.headline)
                                            }).padding()
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }.shadow(radius: 3)
                                
                                // Mid scan area
                                Group {
                                    QRCodeFrameView().padding().shadow(radius: 3)
                                }
                                .frame(width: geo.size.width, height: geo.size.width)
                                .opacity(1.0)
                                
                                // Bottom black bar
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black)
                                        .opacity(0.8)
                                    TimerText()
                                        .font(.headline)
                                        .padding(20)
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                }.shadow(radius: 3)
                            }
                        })
                    }.edgesIgnoringSafeArea(.bottom)
                    .navigationBarTitle("Test")
                    .navigationBarBackButtonHidden(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
                    
                }
            }
            .onTapGesture {
                self.showQRSheet = true
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
                SubmitReportButton(report: report)
            }
            
            // DEBUGGING
//                Section(header: Text("DEBUGGING")) {
//                    Text("Date: \(report.timestamp?.description ?? "No date set yet")")
//                    Text("Latitude: \(report.latitude ?? 0.0)")
//                    Text("Longitude: \(report.longitude ?? 0.0)")
//                    Text("Address: \(report.getAddressAsString())")
//                    Text("QR code: \(report.getQRcodeAsString())")
//                    Text("Brand: \(report.getBrandAsString())")
//                }.foregroundColor(.green)
        }
        .navigationBarTitle("Create Report")
        //.navigationBarItems(trailing: SubmitReportButton(report: report))
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

struct AddressTextView: View {
    @ObservedObject var report: Report
    
    var body: some View {
        switch report.address {
            case .addr(let addr):
                Label(addr, systemImage: "location.fill")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            case .unknown:
                EmptyView()
        }
    }
}


struct SubmitReportButton: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State var showAlert = false
    @ObservedObject var report: Report
    
    
    func submitNoPhotoText() -> String {
        report.hasPhoto() ? "" : "\nTake a photo\n"
    }
    
    func submitNoViolationText() -> String {
        report.hasViolation() ? "" : "\nChoose the type of violation\n"
    }
    
    func submit() -> Void {
        if report.checkIfSubmittable() {
            ReportStore.singleton.uploadReport(report: report)
            self.mode.wrappedValue.dismiss()
        }
        self.showAlert = true
    }
    
    var body: some View {
        Button("Submit", action: {
            submit()
        }).disabled(!report.checkIfSubmittable())
        .onTapGesture(perform: {
            submit()
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

struct QRCodeFrameView: View {
    
    var body: some View {
        GeometryReader(content: { geo in
            Rectangle()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [geo.size.width * 0.5, geo.size.width * 0.5], dashPhase: geo.size.width * 0.25))
                .opacity(0.9)
        })
        
    }
}

struct TimerText: View {
    
    @State var tick = 0
    let timer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Text("Scanning\(String(repeating: ".", count: self.tick + 1))").onReceive(timer) { (_) in
            self.tick += 1
            if self.tick % 3 == 0 {
                self.tick = 0
            }
        }
    }
}


//struct QRCodeFrameView_Preview: PreviewProvider {
//    static var previews: some View {
//        QRCodeFrameView().frame(width: 300, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//    }
//}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView(content: {
            ReportView(report: Report())
        }).navigationBarTitle("Map", displayMode: .large)
    }
}
