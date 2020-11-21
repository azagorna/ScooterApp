import SwiftUI

struct DoneTextField: UIViewRepresentable {
    let placeholder: String
    let keyboardType: UIKeyboardType = .default
    let returnVal: UIReturnKeyType = .done
    @Binding var text: String
    @State var isfocusAble = true
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.tag = 0
        textField.delegate = context.coordinator
        textField.autocorrectionType = .yes
        textField.attributedPlaceholder = NSAttributedString(string: placeholder)
        textField.insertText(text)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if isfocusAble {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: DoneTextField
        
        init(_ textField: DoneTextField) {
            self.parent = textField
        }
        
        func updatefocus(textfield: UITextField) {
            textfield.becomeFirstResponder()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.isfocusAble = false
            parent.text = textField.text ?? "BUG!"
            return true
        }
        
    }
}
