import XCTest
import SwiftUI
@testable import water_mark_app

final class ContentViewTests: XCTestCase {
    
    var contentView: ContentView!
    
    override func setUpWithError() throws {
        contentView = ContentView()
    }
    
    // Тестирование функции добавления водяного знака
    func testAddWatermark() {
        let originalImage = UIImage(systemName: "photo")!
        let watermark = "Тестовый Водяной Знак"
        
        let watermarkedImage = contentView.addWatermark(image: originalImage, watermark: watermark)
        
        XCTAssertNotNil(watermarkedImage, "Изображение с водяным знаком не должно быть nil")
    }
    
    // Тестирование функции сжатия изображения
    func testCompressImage() {
        let originalImage = UIImage(systemName: "photo")!
        let maxFileSize = 1024 * 1024 * 10 // 10 MB
        
        let compressedImage = contentView.compressImage(image: originalImage, maxFileSize: maxFileSize)
        
        XCTAssertNotNil(compressedImage, "Сжатое изображение не должно быть nil")
        
        if let compressedImageData = compressedImage?.jpegData(compressionQuality: 1.0) {
            XCTAssertTrue(compressedImageData.count <= maxFileSize, "Размер сжатого изображения должен быть меньше или равен максимальному размеру файла")
        } else {
            XCTFail("Не удалось получить JPEG данные из сжатого изображения")
        }
    }
    
    // Тестирование позиций водяного знака
    func testWatermarkPosition() {
        let imageSize = CGSize(width: 200, height: 200)
        let textSize = CGSize(width: 50, height: 20)
        
        let positions: [WatermarkPosition: CGPoint] = [
            .topLeft: CGPoint(x: 20, y: 20),
            .topRight: CGPoint(x: imageSize.width - textSize.width - 20, y: 20),
            .bottomLeft: CGPoint(x: 20, y: imageSize.height - textSize.height - 20),
            .bottomRight: CGPoint(x: imageSize.width - textSize.width - 20, y: imageSize.height - textSize.height - 20),
            .center: CGPoint(x: (imageSize.width - textSize.width) / 2, y: (imageSize.height - textSize.height) / 2)
        ]
        
        for (position, expectedPoint) in positions {
            let point = position.point(for: imageSize, textSize: textSize)
            XCTAssertEqual(point, expectedPoint, "Точка для \(position) должна быть \(expectedPoint)")
        }
    }
    
    // Тестирование начального состояния переменных
    func testInitialState() {
        XCTAssertNil(contentView.inputImage, "Начальное значение inputImage должно быть nil")
        XCTAssertFalse(contentView.showingImagePicker, "Начальное значение showingImagePicker должно быть false")
        XCTAssertEqual(contentView.waterMarkText, "", "Начальное значение waterMarkText должно быть пустым")
        XCTAssertFalse(contentView.showSavedAlert, "Начальное значение showSavedAlert должно быть false")
        XCTAssertFalse(contentView.showingSettings, "Начальное значение showingSettings должно быть false")
        XCTAssertEqual(contentView.watermarkPosition, .bottomRight, "Начальное значение watermarkPosition должно быть .bottomRight")
    }
}

