//
//  Image.swift
//  Sunray
//
//  Created by ZhengXun Tu on 2018/9/26.
//  Copyright © 2018 Noodoe. All rights reserved.
//

import UIKit
import Photos

class Image: Codable {
    
    enum Source: RawRepresentable, Codable, Equatable {
        
        typealias RawValue = String
        
        init?(rawValue: String) {
            return nil
        }
        
        var rawValue: String {
            switch self {
            case .url(_):
                return "url"
            case .asset(_):
                return "asset"
            case .empty, .image(_):
                return ""
            }
        }
     
        case empty
        case url(URL)
        case asset(PHAsset)
        case image(UIImage)
        
        static func == (lhs: Source, rhs: Source) -> Bool {
            switch (lhs, rhs) {
            case (let .url(lUrl), let .url(rUrl)):
                return lUrl == rUrl
            case (let .asset(lAsset), let .asset(rAsset)):
                return lAsset.localIdentifier == rAsset.localIdentifier
            default:
                return false
            }
        }
        
    }

    init() {
        self.source = .empty
    }
    
    init(image: UIImage) {
        self.source = .image(image)
    }
    
    init(imageUrl: URL) {
        self.source = .url(imageUrl)
    }

    init(asset: PHAsset) {
        self.source = .asset(asset)
        self.width = asset.pixelWidth
        self.height = asset.pixelHeight
    }

    var url: URL? {
        switch source {
        case .url(let url):
            return url
        default:
            return nil
        }
    }

    var asset: PHAsset? {
        switch source {
        case .asset(let asset):
            return asset
        default:
            return nil
        }
    }
    
    var source: Source
    
    var thumbnailUrl: URL?
    
    var width: Int?
    
    var height: Int?
    
    var ratio: CGFloat? {
        guard let width = width, let height = height, height != 0 else { return nil }
        return CGFloat(width) / CGFloat(height)
    }
    
    //MARK: - Codable
    /*
     https://stackoverflow.com/a/45147203
     */
    enum CodingKeys: String, CodingKey {
        case url = "imageUrl"
        case thumbnailUrl
        case width
        case height
    }
    
    enum CodingError: Error {
        case decode(message: String)
        case encode(message: String)
    }
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let value = try? values.decode(Int.self, forKey: .width) {
            self.width = value
        }
        
        if let value = try? values.decode(Int.self, forKey: .height) {
            self.height = value
        }
        
        if let value = try? values.decode(String.self, forKey: .thumbnailUrl), let url = URL(string: value) {
            self.thumbnailUrl = url
        }
        
        if let value = try? values.decode(String.self, forKey: .url), let url = URL(string: value) {
            self.source = .url(url)
        } else {
            throw CodingError.decode(message: "Key \"url\" is not provided, or it's not a valid url.")
        }
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let width = width {
            try container.encode(width, forKey: .width)
        }
        
        if let height = height {
            try container.encode(height, forKey: .height)
        }
        
        if let thumbnailUrl = thumbnailUrl {
            try container.encode(thumbnailUrl, forKey: .thumbnailUrl)
        }
        
        switch source {
        case .url(let url):
            try container.encode(url.absoluteString, forKey: .url)
        case .asset(_), .empty, .image(_):
            throw CodingError.encode(message: "Encoding is not available.")
        }
        
    }
    
}

extension Image {
    
    /// It is not guaranteed on which thread the completion is dispatched.
    ///
    func downloadImageIfNotExist(_ completion: @escaping ((Bool) -> Void)) {
        guard !imageCacheExists() else {
            completion(true)
            return
        }
        download { data in
            if data != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// It is not guaranteed on which thread the completion is dispatched.
    ///
    func requestData(_ completion: @escaping ((Data?) -> Void)) {
        if let data = loadFromDiskAsData() {
            completion(data)
            return
        }
        download { data in
            completion(data)
        }
    }
    
    /// It is not guaranteed on which thread the completion is dispatched.
    ///
    func requestImage(_ completion: @escaping ((UIImage?) -> Void)) {
        
        switch source {
        case .url(_):
            requestImageViaUrl(completion)
        case .asset(_):
            requestImageViaAsset(completion)
        case .image(let img):
            completion(img)
        case .empty:
            completion(nil)
        }
        
    }
    
    func requestImageViaUrl(_ completion: @escaping ((UIImage?) -> Void)) {
        if let image = loadFromDiskAsUIImage() {
            completion(image)
            return
        }
        download { data in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func requestImageViaAsset(_ completion: @escaping ((UIImage?) -> Void)) {
        
        guard let asset = asset else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            
            let length = UIScreen.main.nativeBounds.width / UIScreen.main.scale
            let size = CGSize(width: length, height: length)
            
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: nil) { img, dict in
                completion(img)
            }
            
        }
        
    }
    
    /// It is not guaranteed on which thread the completion is dispatched.
    ///
    func download(_ completion: @escaping ((Data?) -> Void)) {
        guard let url = url else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
            completion(data)
            guard let self = self else { return }
            if let data = data {
                self.saveToDisk(data)
            }
        }
        task.resume()
    }
    
    private func imageCacheExists() -> Bool {
        guard let url = localUrl() else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    private func directoryUrl() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("Image", isDirectory: true)
    }
    
    private func localUrl() -> URL? {
        guard let url = url else { return nil }
        return directoryUrl()?.appendingPathComponent(url.lastPathComponent)
    }
    
    static let dataQueue = DispatchQueue(label: "com.noodoe.sunray.Image.dataQueue", attributes: .concurrent)
    
    private func saveToDisk(_ data: Data) {
        guard let directoryUrl = directoryUrl(), let url = localUrl() else { return }
        let directoryExists = FileManager.default.fileExists(atPath: directoryUrl.path)
        Image.dataQueue.async(flags: .barrier) {
            if !directoryExists {
                try? FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
            }
            try? data.write(to: url)
        }
    }
    
    func loadFromDiskAsData() -> Data? {
        guard let url = localUrl() else {
            return nil
        }
        var result: Data?
        Image.dataQueue.sync {
            result = try? Data(contentsOf: url)
        }
        return result
    }
    
    func loadFromDiskAsUIImage() -> UIImage? {
        guard let url = localUrl() else {
            return nil
        }
        var result: UIImage?
        Image.dataQueue.sync {
            result = UIImage(named: url.path)
        }
        return result
    }
    
}

extension Image: Equatable {
    
    static func == (lhs: Image, rhs: Image) -> Bool {
        return (lhs.source == rhs.source) &&
                (lhs.thumbnailUrl == rhs.thumbnailUrl) &&
                (lhs.width == rhs.width) &&
                (lhs.height == rhs.height)
    }
    
}
