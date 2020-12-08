//
//  MainView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import SwiftUI
import Foundation

struct MainView: View {
    
    @ObservedObject var locationManager = LocationManager.singleton
    
    var body: some View {
        NavigationView(content: {
            
            ZStack {
                MapView().ignoresSafeArea()
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
        })//.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

