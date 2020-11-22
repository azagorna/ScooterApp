import SwiftUI

struct GetPhotoView: View {
    
    @Binding var photo: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        GeometryReader { geo in
            let squareSize = min(geo.size.width, geo.size.height)
            ZStack {
                // If device has a camera...
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    //...then use it to take a photo
                    Button(action: {
                        sourceType = .camera
                        isImagePickerDisplay.toggle()
                    }) {
                        GetPhotoButtonContentView(image: $photo)
                            .frame(width: squareSize, height: squareSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                } else {
                    //...else pick from camera roll
                    Button(action: {
                        sourceType = .photoLibrary
                        isImagePickerDisplay.toggle()
                    }) {
                        GetPhotoButtonContentView(image: $photo)
                            .frame(width: squareSize, height: squareSize, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                }
            }
        }
        .background(Color.black)
        .sheet(isPresented: $isImagePickerDisplay) {
            CameraPickerView(selectedImage: $photo, sourceType: sourceType).ignoresSafeArea()
        }.ignoresSafeArea()
    }
}

struct GetPhotoButtonContentView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        if image != nil {
            
            Image(uiImage: image!)
                .resizable()
                .aspectRatio(nil, contentMode: .fill)
        } else {
            VStack{
                Text(" ") // Bad solution
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(nil, contentMode: .fit)
                    .font(Font.title.weight(.light))
                    .padding(.horizontal)
                    .frame(minWidth: 0, idealWidth: 100, maxWidth: 120, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 100, maxHeight: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.white)
                Text("Click to take a photo")
                    .foregroundColor(.white)
            }
        }
    }
}

struct GetPhotoView_Preview: PreviewProvider {
    @State static var preview_photo: UIImage? = nil
    
    static var previews: some View {
        GetPhotoView(photo: $preview_photo)
    }
}
