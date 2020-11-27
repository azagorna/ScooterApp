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
                        NavigationLink(destination: ReportsList()) {
                            Label("Reports", systemImage: "photo.on.rectangle.angled")
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
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .cornerRadius(999)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                }.padding()
            }.onAppear(perform: ReportStore.singleton.updateDateFromFirebase)
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

