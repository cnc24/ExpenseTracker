import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case camera, photoLibrary
    }
    
    var sourceType: SourceType
    @Binding var image: UIImage?
    var onTextRecognized: ((String) -> Void)?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        let ocrHelper = OCRHelper()

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                ocrHelper.performOCR(on: uiImage) { recognizedText in
                    self.parent.onTextRecognized?(recognizedText)
                }
            }

            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType == .camera ? .camera : .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct ImagePicker_Previews: PreviewProvider {
    @State static var image: UIImage? = nil

    static var previews: some View {
        ImagePicker(sourceType: .photoLibrary, image: $image)
    }
}
