import Foundation
import UIKit

protocol ImageLoadedListener: AnyObject {
    func imageLoadComplete(image: ImageInfo)
}

class ImageLoader {
    private let imageUrl = "http://www.effectgames.com/demos/canvascycle/image.php?file="
    private let timelineImageUrl = "http://www.effectgames.com/demos/worlds/scene.php?file="
    private var downloading = Set<ImageInfo>()
    private var loadListeners = [ImageLoadedListener]()
    
    private var timelineImages: [ImageCollection] = []
    private var imageCollections: [ImageCollection] = []
    
    init() {
        parseTimelineImages()
        parseImageCollections()
    }
    
    func addListener(_ listener: ImageLoadedListener) {
        loadListeners.append(listener)
    }
    
    func removeListener(_ listener: ImageLoadedListener) {
        loadListeners.removeAll { $0 === listener }
    }
    
    private func parseTimelineImages() {
        guard let url = Bundle.main.url(forResource: "Timelines", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load Timelines.json")
            return
        }
        
        do {
            timelineImages = try JSONDecoder().decode([ImageCollection].self, from: data)
            // Mark all timeline images
            for collection in timelineImages {
                for var image in collection.images {
                    image.isTimeline = true
                }
            }
        } catch {
            print("Failed to parse Timelines.json: \(error)")
        }
    }
    
    private func parseImageCollections() {
        guard let url = Bundle.main.url(forResource: "ImageCollections", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load ImageCollections.json")
            return
        }
        
        do {
            imageCollections = try JSONDecoder().decode([ImageCollection].self, from: data)
        } catch {
            print("Failed to parse ImageCollections.json: \(error)")
        }
    }
    
    func loadImage(_ image: ImageInfo, completion: @escaping (ImageJson?) -> Void) {
        if downloading.contains(image) {
            return
        }
        
        downloading.insert(image)
        
        // Check if image is cached locally first
        if let cachedImage = loadCachedImage(image) {
            completion(cachedImage)
            downloading.remove(image)
            return
        }
        
        // Download from remote URL
        downloadImage(image) { [weak self] jsonString in
            guard let self = self else { return }
            
            if let jsonString = jsonString {
                let parsedImage = self.parseImageJson(jsonString, isTimeline: image.isTimeline)
                self.saveImage(image, jsonString: jsonString)
                completion(parsedImage)
                
                // Notify listeners
                DispatchQueue.main.async {
                    for listener in self.loadListeners {
                        listener.imageLoadComplete(image: image)
                    }
                }
            } else {
                completion(nil)
            }
            
            self.downloading.remove(image)
        }
    }
    
    private func loadCachedImage(_ image: ImageInfo) -> ImageJson? {
        let fileName = image.getFileName()
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                let jsonString = try String(contentsOf: filePath)
                return parseImageJson(jsonString, isTimeline: image.isTimeline)
            } catch {
                print("Failed to load cached image: \(error)")
            }
        }
        
        // Try to load from bundle as fallback
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
            do {
                let jsonString = try String(contentsOf: url)
                return parseImageJson(jsonString, isTimeline: image.isTimeline)
            } catch {
                print("Failed to load bundled image: \(error)")
            }
        }
        
        return nil
    }
    
    private func downloadImage(_ image: ImageInfo, completion: @escaping (String?) -> Void) {
        let fullUrl = getFullUrl(image)
        
        guard let url = URL(string: fullUrl) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Download error for \(image.name): \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for \(image.name)")
                completion(nil)
                return
            }
            
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            let cleanedJson = self.cleanJson(jsonString, isTimeline: image.isTimeline)
            completion(cleanedJson)
            
        }.resume()
    }
    
    private func getFullUrl(_ image: ImageInfo) -> String {
        if image.isTimeline {
            return "\(timelineImageUrl)\(image.getJustId())&month=\(image.month)&script=\(image.script)"
        } else {
            return "\(imageUrl)\(image.id)"
        }
    }
    
    private func cleanJson(_ json: String, isTimeline: Bool) -> String {
        if json.count > 25 {
            if isTimeline {
                if let startIndex = json.range(of: "{base")?.lowerBound {
                    let endIndex = json.index(json.endIndex, offsetBy: -3)
                    return String(json[startIndex..<endIndex])
                }
            } else {
                if let startIndex = json.range(of: "{filename")?.lowerBound {
                    let endIndex = json.index(json.endIndex, offsetBy: -4)
                    return String(json[startIndex..<endIndex])
                }
            }
        }
        return json
    }
    
    private func parseImageJson(_ jsonString: String, isTimeline: Bool) -> ImageJson? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        
        do {
            if isTimeline {
                let timelineJson = try JSONDecoder().decode(TimelineImageJson.self, from: data)
                return timelineJson.base
            } else {
                return try JSONDecoder().decode(ImageJson.self, from: data)
            }
        } catch {
            print("Failed to parse JSON: \(error)")
            return nil
        }
    }
    
    private func saveImage(_ image: ImageInfo, jsonString: String) {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileName = image.getFileName()
        let filePath = documentsPath.appendingPathComponent(fileName)
        
        do {
            try jsonString.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save image \(fileName): \(error)")
        }
    }
    
    func getTimelineCollections() -> [ImageCollection] {
        return timelineImages
    }
    
    func getImageCollections() -> [ImageCollection] {
        return imageCollections
    }
    
    func preloadImages() {
        // Preload a few default images
        for collection in imageCollections.prefix(3) {
            for image in collection.images.prefix(2) {
                loadImage(image) { _ in }
            }
        }
    }
}