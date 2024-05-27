import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var waterMarkText: String = ""
    @State private var showSavedAlert = false

    var body: some View {
        VStack {
            if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(WaterMarkView(waterMarkText: waterMarkText, image: inputImage))
            } else {
                Text("Tap to select a photo")
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("Load Photo") {
                    showingImagePicker = true
                }
                TextField("Enter watermark text", text: $waterMarkText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save Photo") {
                    guard let inputImage = inputImage else { return }
                    let watermarkedImage = WaterMarkView(waterMarkText: waterMarkText, image: inputImage).snapshot()
                    UIImageWriteToSavedPhotosAlbum(watermarkedImage, nil, nil, nil)
                    showSavedAlert = true
                }
            }.padding()

            Spacer()
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
          PhotoPicker(image: $inputImage)
        }
        .alert(isPresented: $showSavedAlert) {
            Alert(title: Text("Saved"), message: Text("Your image has been saved to your photos."), dismissButton: .default(Text("OK")))
        }
    }

    func loadImage() {
        // This function would handle any post-processing after picking the image if needed
    }
}

struct WaterMarkView: View {
    var waterMarkText: String
    var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .overlay(
                Text(waterMarkText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5),
                alignment: .center
            )
    }

    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}



#Preview(){
    ContentView()
}
