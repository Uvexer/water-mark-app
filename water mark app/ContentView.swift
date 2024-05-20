import SwiftUI
import UIKit

struct ContentView: View {
    @State private var image: UIImage?
    @State private var inputText = ""
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }

                TextField("Введите текст", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Загрузить изображение") {
                    showImagePicker = true
                }

                Button("Сохранить текст в изображение") {
                    if let image = image {
                        // Здесь будет вызов функции для встраивания текста
                        embedText(in: image, text: inputText)
                    }
                }
            }
            .navigationTitle("Водяные знаки")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $image, sourceType: .photoLibrary)
            }
        }
    }
    // Функция для встраивания текста в изображение
    func embedText(in image: UIImage, text: String) {
        let textColor = UIColor.white
        let textFont = UIFont.boldSystemFont(ofSize: 12) // You can adjust size as needed

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        let textSize = text.size(withAttributes: textAttributes)
        let rect = CGRect(x: 20, y: 20, width: textSize.width, height: textSize.height) // Adjust text positioning here

        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        text.draw(in: rect, withAttributes: textAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        DispatchQueue.main.async {
            self.image = newImage
        }
    }

}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ContentView()
}

