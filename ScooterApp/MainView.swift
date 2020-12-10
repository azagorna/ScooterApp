import SwiftUI
import MapKit
import Foundation


struct MainView: View {
    
    @ObservedObject var locationManager = LocationManager.singleton
    @ObservedObject var reportStore = ReportStore.singleton
    
    //@ObservedObject private var locations: [MKPointAnnotation] = ReportStore.reportsList as [MKPointAnnotation]
    
    @State private var selectedPlace: MKPointAnnotation?
    @State private var selectedReport: Report? = nil
    @State private var showReport: Bool = false
    
    var body: some View {
        NavigationView(content: {
            ZStack {
                MapView(reportStore: reportStore, selectedReport: $selectedReport, showReport: $showReport).edgesIgnoringSafeArea(.all).disabled(showReport)
                VStack {
                    HStack(alignment: .center) {
                        NavigationLink(destination: ReportsList(reportStore: ReportStore.singleton)) {
                            Label("Reports", systemImage: "photo.on.rectangle.angled")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .font(.body)
                                .cornerRadius(999)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }.navigationBarTitle("Map", displayMode: .large).navigationBarHidden(true)
                        Spacer()
                    }
                    Spacer()
                    NavigationLink(destination: ReportView(report: Report())) {
                        Text("Create Report")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                }.padding()
            }.onAppear(perform: ReportStore.singleton.updateDateFromFirebase)
        }).sheet(isPresented: $showReport) {
            VStack(alignment: .center, spacing: 10) {
                ReportPreview(report: selectedReport!)
            }.navigationBarTitle("Bar Title", displayMode: .inline).navigationBarItems(trailing: Button("Done",
                                                                                                        action: {}))
        }
        //                .toolbar {
        //                    ToolbarItem(placement: .primaryAction) {
        //                        Button(action: {
        //                            self.showReport = false
        //                        }) {
        //                            Text("Back").fontWeight(.semibold)
        //                        }
        //                    }
        //                }
        //        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

