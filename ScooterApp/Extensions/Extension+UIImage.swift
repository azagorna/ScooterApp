import SwiftUI
import UIKit


extension UIImage {

    func squareCropImage() -> UIImage {
        let width: CGFloat  = self.size.width
        let height: CGFloat = self.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var newlength: CGFloat = 0.0
                
        if (width > height) { // if landscape
            newlength = height
            x = (width - newlength) / 2.0
            y = 0.0
        } else if (height > width) { // if portrait
            newlength = width
            x = 0.0
            y = (height - width) / 2.0
        } else { // else already square
            newlength = width
        }
        
        let cropSquare = CGRect(x: x, y: y, width: newlength, height: newlength)
        let imageRef = self.cgImage!.cropping(to: cropSquare);
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: self.imageOrientation)
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
