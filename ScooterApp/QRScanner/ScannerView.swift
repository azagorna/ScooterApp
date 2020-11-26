import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel = ScannerViewModel()
    @Binding var qrCode: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            QrCodeScannerView()
                .found(result: { (foundQRcode: String) in
                    print(".found() before: \(foundQRcode)")
                    qrCode = foundQRcode
                    isPresented = false
                    print(".found() after: \(foundQRcode)")
                })
                .interval(delay: 1.0)
                .torchLight(isOn: false)
            
            VStack {
                Spacer(minLength: 10)
                Button("Close", action: {isPresented = false})
                Spacer()
            }

            //            VStack {
            //                VStack {
            //                    Text("Keep scanning for QR-codes")
            //                        .font(.subheadline)
            //                    Text(self.viewModel.lastQrCode)
            //                        .bold()
            //                        .lineLimit(5)
            //                        .padding()
            //                }
            //                .padding(.vertical, 20)
            //
            //                Spacer()
            //                HStack {
            //                    Button(action: {
            //                        self.viewModel.torchIsOn.toggle()
            //                    }, label: {
            //                        Image(systemName: self.viewModel.torchIsOn ? "bolt.fill" : "bolt.slash.fill")
            //                            .imageScale(.large)
            //                            .foregroundColor(self.viewModel.torchIsOn ? Color.yellow : Color.blue)
            //                            .padding()
            //                    })
            //                }
            //                .background(Color.white)
            //                .cornerRadius(10)
            //
            //            }.padding()
        }
    }
}
