import Foundation

// MARK: - JSON Data Models

struct ColorJson: Codable {
    let rgb: [Int]
    
    var rgbValue: UInt32 {
        return UInt32((rgb[0] << 16) | (rgb[1] << 8) | rgb[2])
    }
}

struct ImageJson: Codable {
    let width: Int
    let height: Int
    let colors: [ColorJson]
    let cycles: [Cycle]
    let pixels: [Int]
    
    func getParsedColors() -> [UInt32] {
        return colors.map { $0.rgbValue }
    }
}

struct PaletteJson: Codable {
    let colors: [ColorJson]
    let cycles: [Cycle]
    
    var parsedColors: [UInt32] {
        return colors.map { $0.rgbValue }
    }
}

struct ImageInfo: Codable, Hashable {
    let id: String
    let name: String
    var isTimeline: Bool = false
    var month: Int = 0
    var script: String = ""
    
    func getJustId() -> String {
        return id
    }
    
    func getFileName() -> String {
        return "\(id).json"
    }
    
    static func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ImageCollection: Codable {
    let name: String
    let images: [ImageInfo]
}

struct TimelineImageJson: Codable {
    let base: ImageJson
    let basefilename: String
    let times: [String: ImageJson]
}

// MARK: - Default Data

func defaultImageJson() -> ImageJson {
    let blackColor = ColorJson(rgb: [0, 0, 0])
    let defaultColors = Array(repeating: blackColor, count: 256)
    let defaultPixels = Array(repeating: 0, count: 307200) // 640 * 480
    
    return ImageJson(
        width: 640,
        height: 480,
        colors: defaultColors,
        cycles: [],
        pixels: defaultPixels
    )
}