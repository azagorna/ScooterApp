import SwiftUI

struct ReportPreview: View {
    
    @ObservedObject var report: Report
    @Environment(\.presentationMode) var presentationMode
    @State private var showActionSheet = false
    
    var body: some View {
        Form {
            Section (header: Text("Photo"), footer: AddressTextView(report: report)) {
                GeometryReader(content: { geometry in
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                        if report.hasPhoto() {
                            Image(uiImage: (report.photo ?? UIImage(systemName: "questionmark")!))
                                .resizable()
                                .aspectRatio(nil, contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
                                .clipped()
                        }
                        if !report.hasPhoto() {
                            ProgressView("Loading photo \(Int(report.photoDownloadProgress * 100))%", value: report.photoDownloadProgress).padding(100).frame(width: geometry.size.width, height: geometry.size.width, alignment: .center)
                        }
                    }
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
                    ViolationLabel(text: "Was misplaced")
                }
                if report.laying {
                    ViolationLabel(text: "Was laying")
                }
                if report.broken {
                    ViolationLabel(text: "Was broken")
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
            Section (header: Text("Delete Report")) {
                Button(action: { self.showActionSheet = true }) {
                    Label("Delete", systemImage: "trash").font(.headline).foregroundColor(.red)
                }.actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Warning!"), message: Text("Are you sure you want to delete this report?"),
                                buttons: [.cancel(), .destructive(Text("Delete")) {
                                    print("Deleted!")
                                    self.presentationMode.wrappedValue.dismiss()
                                    ReportStore.singleton.deleteReport(report: report)
                                }])
                }
            }
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
        ReportPreview(report: Report())
    }
}
