//
//  CameraView.swift
//  ScooterApp
//
//  Created by Gabriel Brodersen on 05/11/2020.
//

import SwiftUI

struct CameraScreenView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            Text("TODO: Take Photo")
                .foregroundColor(.white)
            VStack {
                Spacer()
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }
                .navigationBarTitle("Camera", displayMode: .inline)
                .foregroundColor(.white)
        }

    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScreenView()
    }
}
