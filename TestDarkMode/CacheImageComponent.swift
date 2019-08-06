//
//  CacheImageView.swift
//  TZXSwift
//
//  Created by 塗政勳 on 31/03/2017.
//  Copyright © 2017 Aengin Technology Inc. All rights reserved.
//

import UIKit

fileprivate let cacheImageComponentQueue = DispatchQueue(label: "com.noodoe.sunray.cacheImageComponentQueue")

protocol CacheImageComponent: class {
    var cacheKey: String? { set get }
    func setImage(_ image: UIImage?)
    func setImage(_ image: UIImage?, for state: UIControl.State)
}

extension CacheImageComponent {
    
    /// - Attention: Make sure you call this method on the Main Thread
    ///
    func setImageUrl(_ urlString: String?, placeholder: UIImage?, diskCache: Bool = true, completion: ((_ imageExists: Bool) -> Void)? = nil) {
        setImage(placeholder)
        guard let cacheKey = urlString, let urlString = urlString, let url = URL(string: urlString) else {
            completion?(false)
            return
        }
        self.cacheKey = urlString
        
        cacheImageComponentQueue.async {
            if let cache = CICCacheManager.shared.image(forKey: cacheKey) {
                DispatchQueue.main.async {
                    self.setImage(cache)
                    completion?(true)
                }
                return
            } else if let filename = filenameForUrlString(urlString), let cache = CICCacheManager.shared.imageOnDisk(named: filename) {
                DispatchQueue.main.async {
                    self.setImage(cache)
                    completion?(true)
                }
                CICCacheManager.shared.setImage(cache, forKey: cacheKey)
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
                guard let strongSelf = self else {
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    CICCacheManager.shared.setImage(image, forKey: cacheKey)
                    if diskCache, let filename = filenameForUrlString(urlString) {
                        CICCacheManager.shared.save(image, toDiskWithName: filename)
                    }
                    DispatchQueue.main.async {
                        if cacheKey == strongSelf.cacheKey {
                            strongSelf.setImage(image)
                        }
                        completion?(true)
                    }
                }
            }
            task.resume()
        }
    }
    
    func cacheKey(for image: Image) -> String? {
        switch image.source {
        case .url(let url):
            return url.absoluteString
        case .asset(let asset):
            return asset.localIdentifier
        case .image(let image):
            return "\(image.hashValue)"
        case .empty:
            return nil
        }
    }
    
    func setNDImage(_ image: Image?, placeholder: UIImage? = nil, completion: ((_ imageExists: Bool) -> Void)? = nil) {
        guard let image = image, image.source != .empty, let cacheKey = cacheKey(for: image) else {
            setImage(nil)
            completion?(false)
            return
        }
        self.cacheKey = cacheKey
        if let cache = CICCacheManager.shared.image(forKey: cacheKey) {
            setImage(cache)
            completion?(true)
        } else {
            switch image.source {
            case .url(let url):
                setImageUrl(url.absoluteString, placeholder: placeholder, completion: completion)
            case .asset(_):
                setImage(placeholder)
                image.requestImage { [weak self] img in
                    guard let strongSelf = self else {
                        return
                    }
                    if let img = img {
                        DispatchQueue.main.async {
                            CICCacheManager.shared.setImage(img, forKey: cacheKey)
                            if cacheKey == strongSelf.cacheKey {
                                strongSelf.setImage(img)
                            }
                        }
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            case .image(let img):
                setImage(img)
                completion?(true)
            case .empty:
                completion?(false)
            }
        }
    }
    
    func setImage(_ image: UIImage?, for state: UIControl.State) {}
    
}

final class CacheImageButton: UIButton, CacheImageComponent {
    
    var cacheKey: String?
    
    var roundCorner = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            imageView.layer.cornerRadius = roundCorner ? imageView.bounds.width / 2 : 0
        }
    }
    
    func setImage(_ image: UIImage?) {
        setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
}

final class CacheImageView: UIImageView, CacheImageComponent {
    
    var cacheKey: String?
    
    func setImage(_ image: UIImage?) {
        self.image = image
    }
    
}

fileprivate func filenameForUrlString(_ urlString: String) -> String? {
    return URL(string: urlString)?.lastPathComponent
}

fileprivate final class DiscardableImageCacheContent: NSObject, NSDiscardableContent {
    
    private(set) var image: UIImage?
    private var accessCount: UInt = 0
    
    init(image: UIImage) {
        self.image = image
    }
    
    func beginContentAccess() -> Bool {
        if image == nil {
            return false
        }
        accessCount += 1
        return true
    }
    
    func endContentAccess() {
        if accessCount > 0 {
            accessCount -= 1
        }
    }
    
    func discardContentIfPossible() {
        if accessCount == 0 {
            image = nil
        }
    }
    
    func isContentDiscarded() -> Bool {
        return image == nil
    }
    
}

class CICCacheManager {
    
    fileprivate static let shared = CICCacheManager()
    
    private let dataQueue = DispatchQueue(label: "com.noodoe.sunray.CICCacheManager.dataQueue", attributes: .concurrent)
    private let cache = NSCache<NSString,DiscardableImageCacheContent>()
    
    fileprivate enum ImageFormat {
        case jpeg
        case png
    }
    
    private init() {
        if let directoryUrl = CICCacheManager.directoryUrl() {
            var isDir : ObjCBool = false
            if !FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: &isDir) {
                do {
                    try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    #if DEBUG
                    print("CICCacheManager unable to create cache directory. \nError: \(error)")
                    #endif
                }
            }
        }
    }
    
    fileprivate func setImage(_ image: UIImage, forKey key: String) {
        dataQueue.async(flags: .barrier) {
            let cachedItem = DiscardableImageCacheContent(image: image)
            self.cache.setObject(cachedItem, forKey: key as NSString)
        }
    }
    
    fileprivate func image(forKey key: String) -> UIImage? {
        var result: UIImage?
        dataQueue.sync {
            result = cache.object(forKey: key as NSString)?.image
        }
        return result
    }
    
    fileprivate func save(_ image: UIImage, toDiskWithName filename: String, format: ImageFormat = .jpeg) {
        dataQueue.async(flags: .barrier) {
            var data: Data!
            switch format {
            case .jpeg:
                data = image.jpegData(compressionQuality: 1.0)
            case .png:
                data = image.pngData()
            }
            
            guard
                data != nil,
                let fullFilePathURL = CICCacheManager.fileUrl(for: filename)
                else { return }
            
            try? data.write(to: fullFilePathURL, options: .atomic)
        }
    }
    
    fileprivate func imageOnDisk(named filename: String) -> UIImage? {
        var result: UIImage?
        dataQueue.sync {
            if
                let fullFilePathURL = CICCacheManager.fileUrl(for: filename),
                let image = UIImage(named: fullFilePathURL.path)
            {
                result = image
            }
        }
        return result
    }
    
    private static func fileUrl(for filename: String) -> URL? {
        return directoryUrl()?.appendingPathComponent(filename)
    }
    
    private static func directoryUrl() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("CICCacheManager", isDirectory: true)
    }
    
    static func clearCachesCreatedBefore(_ value: Int, _ unit: Calendar.Component) {
        guard let pathUrl = directoryUrl() else { return }
        do {
            let now = Date()
            try FileManager.default
                .contentsOfDirectory(at: pathUrl, includingPropertiesForKeys: [.creationDateKey], options: [])
                .filter { url in
                    guard
                        let creationDate = try url.resourceValues(forKeys: [.creationDateKey]).creationDate,
                        let difference = now.ordinalDifference(of: unit, from: creationDate, in: .era)
                        else { return false }
                    return difference > value
                }
                .forEach { try FileManager.default.removeItem(at: $0) }
        } catch {
            #if DEBUG
            print("CICCacheManager unable to clear cache. \nError: \(error)")
            #endif
        }
    }
    
}
