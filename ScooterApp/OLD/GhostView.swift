//
//  GhostView.swift
//  ScooterApp
//
//  Created by Agnieszka Zagórna and Gabriel Brodersen on 15/10/2020.
//

import SwiftUI

struct GhostView: View {

    @State private var _counter = 0
    var showGhost: Bool { _counter > 0 && _counter % 10 == 0 }
    var fontSize: CGFloat { showGhost ? CGFloat(200.0) : CGFloat(24.0) }
    var labelText: String { showGhost ? "👻" : "Clicked: \(_counter)" }

    var body: some View {
        VStack {
            Spacer()
            if showGhost {
                Text("👻")
                    .font(.system(size: fontSize))
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5)))
//                    .transition(.slide)
//                    .animation(.easeInOut(duration: 1))

            } else {
                Text("Clicked: \(_counter)")
                    .font(.title)
            }

            Spacer()
            Button(action: increaseCounter) {
                Label("Increase counter", systemImage: "plus.circle")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .cornerRadius(8.0)
            }
        }
    }

    func increaseCounter() {
        _counter += 1
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GhostView()
    }
}
