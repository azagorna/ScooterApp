//
//  ImagePicker.swift
//  ScooterApp
//
//  Created by Agnieszka Zagórna on 15/11/2020.
//

//import SwiftUI
//import UIKit
//
//typealias PickedImageHandler = (UIImage?) -> Void
//
//struct ImagePicker: UIViewControllerRepresentable {
//    var handlePickedImage: PickedImageHandler
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.sourceType = .camera
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(handlePickedImage: handlePickedImage)
//    }
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var handlePickedImage: PickedImageHandler
//
//        init(handlePickedImage: @escaping PickedImageHandler) {
//            self.handlePickedImage = handlePickedImage
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            handlePickedImage(info[.originalImage] as? UIImage)
//        }
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            handlePickedImage(nil)
//        }
//    }
//}
