import SwiftUI

struct ReportsList: View {
    
    @ObservedObject var reportStore: ReportStore
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        List {
            ForEach(self.reportStore.reportsList) { report in
                NavigationLink(destination: ReportPreview(report: report)) {
                    HStack() {
                        ReportImageListThumbnail(report: report)
                        VStack(){
                            Spacer()
                            Text(formatDate(date: report.timestamp!))
                                .font(.headline)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            Spacer()
                            Text(report.getAddressAsString())
                                .font(.footnote)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            Spacer()
                        }.frame(alignment: .leading)
                    }.frame(alignment: .leading)
                }.buttonStyle(PlainButtonStyle())
                
            }.onDelete(perform: { indexSet in
                indexSet.forEach { index in
                    if reportStore.reportsList.indices.contains(index) {
                        reportStore.deleteReport(report: reportStore.reportsList[index])
                    }
                }
            })
        }.navigationBarTitle("Reports", displayMode: .inline)
        
    }
}

struct ReportsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView(content: {
                ReportsList(reportStore: ReportStore.singleton)
            })
            NavigationView(content: {
                ReportsList(reportStore: ReportStore.singleton)
            })
        }
    }
}

struct ReportImageListThumbnail: View {
    
    @ObservedObject var report: Report
    
    var body: some View {
        ZStack {
            if report.hasPhoto() {
                Image(uiImage: (report.photo ?? UIImage(systemName: "questionmark")!))
                    .resizable()
                    .aspectRatio(nil, contentMode: .fill)
                    .frame(width: 72, height: 72, alignment: .center)
                    .clipped()
                    .cornerRadius(8.0)
            }
            if !report.hasPhoto() {
                ProgressView().cornerRadius(8.0)
            }
        }.frame(width: 72, height: 72, alignment: .center)
    }
}
