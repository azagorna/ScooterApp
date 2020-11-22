import SwiftUI

struct ReportsList: View {
    
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    func getReportPhoto(_ report: Report) -> UIImage {
        return ReportStore.singleton.findPhoto(filename: report.photoFilename)
    }
    
    var body: some View {
        List{
            ForEach(ReportStore.singleton.getReportsListByDate()) { report in
                NavigationLink(destination: ReportPreview(report: report, photo: getReportPhoto(report))) {
                    HStack() {
                        Image(uiImage: getReportPhoto(report))
                            .resizable()
                            .cornerRadius(8)
                            .aspectRatio(nil, contentMode: .fill)
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipped()
                        
                        VStack(){
                            Text(
                                formatDate(date: report.timestamp!))
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                }
            }
        }.navigationBarTitle("My reports", displayMode: .inline)
    }
}

struct ReportsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsList()
    }
}
