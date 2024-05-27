import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var waterMarkText: String = ""
    @State private var showSavedAlert = false
    @State private var showingSettings = false

    var body: some View {
        VStack {
            HStack {
                Text("Водяные Знаки")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Text(Image(systemName: "info.circle"))
                        .font(.largeTitle)
                        .padding()
                }
            }

            Spacer()

            if let inputImage = inputImage {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(Text(waterMarkText)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(5)
                                .padding(), alignment: .bottom)
            } else {
                Text("Tap to select a photo")
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack {
                HStack {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Load Photo")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(10)
                    }

                    TextField("Enter watermark text", text: $waterMarkText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        guard let inputImage = inputImage else { return }
                        let watermarkedImage = addWatermark(image: inputImage, watermark: waterMarkText)
                        if let compressedImage = compressImage(image: watermarkedImage, maxFileSize: 30 * 1024 * 1024) {
                            UIImageWriteToSavedPhotosAlbum(compressedImage, nil, nil, nil)
                            showSavedAlert = true
                        }
                    }) {
                        Text("Save Photo")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }

        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            PhotoPicker(image: $inputImage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .presentationDetents([.medium])
        }
        .alert(isPresented: $showSavedAlert) {
            Alert(title: Text("Saved"), message: Text("Your image has been saved to your photos."), dismissButton: .default(Text("OK")))
        }
    }

    func loadImage() {}
    
    func compressImage(image: UIImage, maxFileSize: Int) -> UIImage? {
        var compression: CGFloat = 1.0
        guard var imageData = image.jpegData(compressionQuality: compression) else { return nil }

        while imageData.count > maxFileSize && compression > 0 {
            compression -= 0.1
            guard let newImageData = image.jpegData(compressionQuality: compression) else { break }
            imageData = newImageData
        }

        return UIImage(data: imageData)
    }

    func addWatermark(image: UIImage, watermark: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: CGPoint.zero)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .backgroundColor: UIColor.black.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle
            ]

            let string = NSString(string: watermark)
            let textSize = string.size(withAttributes: attrs)
            let textRect = CGRect(x: (image.size.width - textSize.width) / 2,
                                  y: image.size.height - textSize.height - 20,
                                  width: textSize.width,
                                  height: textSize.height)

            string.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
