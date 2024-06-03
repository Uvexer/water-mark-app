import SwiftUI
import PhotosUI

struct ContentView: View {
    @State var inputImage: UIImage?
    @State var showingImagePicker = false
    @State var waterMarkText: String = ""
    @State var showSavedAlert = false
    @State var showingSettings = false
    @State var watermarkPosition: WatermarkPosition = .bottomRight
    
    var publicInputImage: UIImage? {
        inputImage
    }
    
//интерфейс основного экрана
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
                    .overlay(
                        Text(waterMarkText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(5)
                            .padding(),
                        alignment: watermarkPosition.alignment
                    )
            } else {
                Text("Фото для водяного знака")
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack {
                HStack {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Загрузить")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .background(Color.green.opacity(0.5))
                            .cornerRadius(10)
                    }

                    TextField("", text: $waterMarkText)
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
                        Text("Сохранить")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.5))
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(10)
                    }
                }
                .padding()

                Picker("Положение водяного знака", selection: $watermarkPosition) {
                    ForEach(WatermarkPosition.allCases, id: \.self) { position in
                        Text(position.displayText).tag(position)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
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
            Alert(title: Text("Сохранено"), message: Text("Фото с водяным знаком сохранено"), dismissButton: .default(Text("OK")))
        }
    }

    func loadImage() {}
    
    //для сжатия изображения
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
//добавление водяного знака
    func addWatermark(image: UIImage, watermark: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: CGPoint.zero)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: image.size.width / 10),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .backgroundColor: UIColor.black.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle
            ]

            let string = NSString(string: watermark)
            let textSize = string.size(withAttributes: attrs)
            let textPoint = watermarkPosition.point(for: image.size, textSize: textSize)

            let textRect = CGRect(origin: textPoint, size: textSize)

            string.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
    
}
//позиция водяного знака
enum WatermarkPosition: String, CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight, center
    
    var displayText: String {
        switch self {
        case .topLeft: return "⬆️⬅️"
        case .topRight: return "⬆️➡️"
        case .bottomLeft: return "⬇️⬅️"
        case .bottomRight: return "⬇️➡️"
        case .center: return "⚪️"
        }
    }
    
    var alignment: Alignment {
        switch self {
        case .topLeft: return .topLeading
        case .topRight: return .topTrailing
        case .bottomLeft: return .bottomLeading
        case .bottomRight: return .bottomTrailing
        case .center: return .center
        }
    }
    
    func point(for imageSize: CGSize, textSize: CGSize) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: 20, y: 20)
        case .topRight:
            return CGPoint(x: imageSize.width - textSize.width - 20, y: 20)
        case .bottomLeft:
            return CGPoint(x: 20, y: imageSize.height - textSize.height - 20)
        case .bottomRight:
            return CGPoint(x: imageSize.width - textSize.width - 20, y: imageSize.height - textSize.height - 20)
        case .center:
            return CGPoint(x: (imageSize.width - textSize.width) / 2, y: (imageSize.height - textSize.height) / 2)
        }
    }
    
}
