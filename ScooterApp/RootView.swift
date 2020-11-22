//
//  MainView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import SwiftUI

struct RootView: View {
    
    @State private var screen: String? = "map"
    @ObservedObject var locationManager = LocationManager.singleton
    
    
    var body: some View {
        NavigationView(content: {
            
            ZStack {
                MapView().ignoresSafeArea()
                VStack {
                    NavigationLink(destination: ReportsList(), tag: "reports", selection: $screen) {
                        EmptyView()
                    }.navigationBarTitle("Map", displayMode: .large).navigationBarHidden(true)
                    //.transition(.move(edge: .bottom))
                    
                    
                    HStack(alignment: .center) {
                        Button(action: { self.screen = "reports" }) {
                            Label("Reports", systemImage: "photo.on.rectangle.angled")
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .font(.body)
                                .cornerRadius(999)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                        Spacer()
                    }
                    Spacer()
                    NavigationLink(destination: ReportView(report: Report(), readOnly: false), tag: "report", selection: $screen) {
                        EmptyView()
                    }
                    Button(action: { self.screen = "report" }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .cornerRadius(999)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                    .buttonStyle(DefaultButtonStyle())
                }.padding()
            }.onAppear(perform: ReportStore.singleton.downloadReports).onAppear(perform: {print("GETTING DATA FROM FIREBASE")})
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

