//
//  WePhotoHelper.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//

import UIKit
import SwiftUICore
import Combine

@available(iOS 14.0, *)
public class WePhotoUIKit {
    
    public init() {}
    
    nonisolated(unsafe) private static var cancellables: Set<AnyCancellable> = []
    
    // URL üzerinden görsel yükler ve alt metin ekler
    @MainActor
    public static func setImageWithURL(
        _ imageView: UIImageView,
        urlString: String,
        placeholder: UIImage? = nil
    ) {
        guard let url = URL(string: urlString) else { return }
        @StateObject var altTextCache = URLDataCache.shared
        @State var altText: String = "No Image Description"
        
        imageView.image = placeholder
        
        if let cachedItem = altTextCache.getItem(byImageUrl: urlString) {
            altText = cachedItem.imageUrl
        } else {
            altTextCache.save([URLDataModel(imageUrl: urlString, imageType: "url")])
        }
        
        // Görseli yükle
        imageView.load(url: url)
        imageView.accessibilityLabel = altText
        
        altTextCache.objectWillChange
            .sink { [weak imageView] _ in
                if let updatedItem = altTextCache.getItem(byImageUrl: urlString) {
                    DispatchQueue.main.async {
                        imageView?.accessibilityLabel = updatedItem.shortImageCaption ?? "No Image Description"
                    }
                }
            }
            .store(in: &cancellables)
        
    }
    
    // Asset üzerinden görsel yükler ve alt metin ekler
    @MainActor
    public static func setImageWithAsset(
        _ imageView: UIImageView,
        assetName: String
    ) {
        @StateObject var altTextCache = URLDataCache.shared
        @State var altText: String = "No Image Description"
        
        if let cachedItem = altTextCache.getItem(byImageUrl: assetName) {
            altText = cachedItem.imageUrl
        } else {
            altTextCache.save([URLDataModel(imageUrl: assetName, imageType: "asset")])
        }
        
        
        imageView.image = UIImage(named: assetName)
        imageView.accessibilityLabel = altText
        
        altTextCache.objectWillChange
            .sink { [weak imageView] _ in
                if let updatedItem = altTextCache.getItem(byImageUrl: assetName) {
                    DispatchQueue.main.async {
                        imageView?.accessibilityLabel = updatedItem.shortImageCaption ?? "No Image Description"
                    }
                }
            }
            .store(in: &cancellables)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
