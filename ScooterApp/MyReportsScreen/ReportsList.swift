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
                        Group{
                        Image(uiImage: self.getReportPhoto(report))
                            .resizable()
                            .aspectRatio(nil, contentMode: .fill)
                            .frame(width: 72, height: 72, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                        }
                        VStack(){
                            Spacer()
                            Text(formatDate(date: report.timestamp!))
                                .font(.headline)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            Spacer()
                            //Label(report.getAddressAsString(), systemImage: "location.fill").font(.footnote).lineLimit(2)
                            Text(report.getAddressAsString())
                                .font(.footnote)
                                .lineLimit(1)
                                .frame(alignment: .leading)
                            Spacer()
                        }.frame(alignment: .leading)
                    }.frame(alignment: .leading)
                }.buttonStyle(PlainButtonStyle())
            }
        }.navigationBarTitle("My reports", displayMode: .inline).onAppear(perform: {
            print()
            print("Reports:")
            print(ReportStore.singleton.reports.debugDescription)
            print()
            print("Photos:")
            print(ReportStore.singleton.photos.debugDescription)
            print()
        })
    }
}

struct ReportsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView(content: {
        ReportsList()
        })
    }
}
