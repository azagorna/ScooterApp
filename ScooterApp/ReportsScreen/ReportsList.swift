import SwiftUI

struct ReportsList: View {
    

    //let reports = ["Report1", "Report2", "Report3", "..."]
    
//TODO: change UUID to something readable, but what? Date?
//TODO: maybe fix the double navigation bar
    

    var body: some View
    {
        NavigationView {
<<<<<<< HEAD
                List(ReportStore.singleton.reports, id: \.self) { report in
                    NavigationLink(destination: ReportView(report: report, readOnly: true)) {
                                    Label(report.id.uuidString, systemImage: "photo")
=======
                List(ReportStore.shared.reports, id: \.self) { report in
                    NavigationLink(destination: ReportView().environmentObject(report)) {
//                        Label(report.id.uuidString, report.photo.)
                        HStack() {
                            Image(uiImage: report.photo!)
                                .resizable()
                                .aspectRatio(nil, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                
                            Spacer(minLength: 15)
                            VStack(){
                                Text(
                                report.timestamp!.description(with: Locale.current))
                                .lineLimit(1)
                            }
                        }
>>>>>>> origin/agza2
                    }
                }.navigationBarTitle("My reports", displayMode: .inline)
        }
    }
}
    
struct ReportsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsList()
    }
}
