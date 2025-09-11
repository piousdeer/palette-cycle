import Foundation
import UIKit

class PaletteCycleEngine {
    private var imageJson: ImageJson?
    private var palette: Palette?
    private var bitmap: UIImage?
    private var startTime: Date
    private var isRunning = false
    private var displayLink: CADisplayLink?
    
    weak var delegate: PaletteCycleEngineDelegate?
    
    init() {
        self.startTime = Date()
        loadDefaultImage()
    }
    
    private func loadDefaultImage() {
        // Load the default image from bundle
        if let url = Bundle.main.url(forResource: "DefaultImage", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let jsonString = String(data: data, encoding: .utf8) {
            
            do {
                let imageJson = try JSONDecoder().decode(ImageJson.self, from: data)
                setImage(imageJson)
            } catch {
                print("Failed to load default image: \(error)")
                setImage(defaultImageJson())
            }
        } else {
            setImage(defaultImageJson())
        }
    }
    
    func setImage(_ imageJson: ImageJson) {
        self.imageJson = imageJson
        self.palette = Palette(colors: imageJson.getParsedColors(), cycles: imageJson.cycles)
        createBitmap()
        restart()
    }
    
    private func createBitmap() {
        guard let imageJson = imageJson else { return }
        
        let width = imageJson.width
        let height = imageJson.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        // Convert palette indices to RGB pixels
        for (index, paletteIndex) in imageJson.pixels.enumerated() {
            let pixelOffset = index * bytesPerPixel
            
            if paletteIndex < imageJson.colors.count {
                let color = imageJson.colors[paletteIndex].rgbValue
                pixelData[pixelOffset] = UInt8((color >> 16) & 0xFF)     // Red
                pixelData[pixelOffset + 1] = UInt8((color >> 8) & 0xFF) // Green
                pixelData[pixelOffset + 2] = UInt8(color & 0xFF)        // Blue
                pixelData[pixelOffset + 3] = 255                         // Alpha
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        if let cgImage = context?.makeImage() {
            bitmap = UIImage(cgImage: cgImage)
        }
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        startTime = Date()
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func restart() {
        if isRunning {
            stop()
            start()
        }
    }
    
    @objc private func update() {
        guard let palette = palette,
              let imageJson = imageJson else { return }
        
        let timePassed = Int(Date().timeIntervalSince(startTime) * 1000) // Convert to milliseconds
        
        // Cycle the palette
        palette.cycle(timePassed: timePassed)
        
        // Update the bitmap with new colors
        updateBitmap(palette: palette, imageJson: imageJson)
        
        // Notify delegate
        delegate?.paletteCycleEngineDidUpdate(self)
    }
    
    private func updateBitmap(palette: Palette, imageJson: ImageJson) {
        let width = imageJson.width
        let height = imageJson.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let colors = palette.getColors()
        
        // Convert palette indices to RGB pixels with cycled colors
        for (index, paletteIndex) in imageJson.pixels.enumerated() {
            let pixelOffset = index * bytesPerPixel
            
            if paletteIndex < colors.count {
                let color = colors[paletteIndex]
                pixelData[pixelOffset] = UInt8((color >> 16) & 0xFF)     // Red
                pixelData[pixelOffset + 1] = UInt8((color >> 8) & 0xFF) // Green
                pixelData[pixelOffset + 2] = UInt8(color & 0xFF)        // Blue
                pixelData[pixelOffset + 3] = 255                         // Alpha
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        if let cgImage = context?.makeImage() {
            bitmap = UIImage(cgImage: cgImage)
        }
    }
    
    func getCurrentBitmap() -> UIImage? {
        return bitmap
    }
}

protocol PaletteCycleEngineDelegate: AnyObject {
    func paletteCycleEngineDidUpdate(_ engine: PaletteCycleEngine)
}