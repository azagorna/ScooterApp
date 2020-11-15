//
//  MainView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import SwiftUI

struct MainView: View {
    
    @State private var screen: String? = "map"
    @ObservedObject var locationManager = LocationManager()
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView(content: {
            
            ZStack {
                MapView().ignoresSafeArea()
                VStack {
                    NavigationLink(destination: ReportsScreenView(), tag: "reports", selection: $screen) {
                        EmptyView()
                    }.navigationBarTitle("Map", displayMode: .inline).navigationBarHidden(true)
                    
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
                    NavigationLink(destination: CameraScreenView(), tag: "camera", selection: $screen) {
                        EmptyView()
                    }
                    Button(action: { self.screen = "camera"
                        self.showImagePicker = true
                    }) {
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
            }
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
