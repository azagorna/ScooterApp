import SwiftUI

struct ReportsList: View {
    
//TODO: maybe fix the double navigation bar

    var body: some View
    {
        NavigationView {
                List(ReportStore.shared.reports, id: \.self) { report in
                    NavigationLink(destination: ReportView().environmentObject(report)) {
                                    Label(report.id.uuidString, systemImage: "photo")
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
