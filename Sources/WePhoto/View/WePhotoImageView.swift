//
//  WePhotoImageView.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//

import SwiftUI

@available(iOS 15.0, *)
public struct WePhotoImageView: View {
    let imageUrl: String?
    let assetImageName: String?
    
    var width: CGFloat? = 200
    var height: CGFloat? = 200
    
    @StateObject private var altTextCache = URLDataCache.shared
    @State private var altText: String = ""
    
    public init(imageUrl: String?, assetImageName: String?) {
        self.imageUrl = imageUrl
        self.assetImageName = assetImageName
    }

    public var body: some View {
        VStack {
            if let urlString = imageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: self.width, height: self.height)
                        .onAppear {
                            Task {
                                if let cachedItem = altTextCache.getItem(byImageUrl: urlString) {
                                    if (cachedItem.shortImageCaption != nil) {
                                        altText = cachedItem.shortImageCaption!
                                    }
                                } else {
                                    altTextCache.save([URLDataModel(imageUrl: urlString, imageType: "url")])
                                }
                            }
                        }
                        .onTapGesture {
                            print("tapped..")
                            print("accessibility text:: \(altText)")
                        }
                        .accessibilityLabel(altText)
                        
                } placeholder: {
                    ProgressView()
                }
            }
            // Asset üzerinden görsel yükleme
            else if let assetImageName = assetImageName {
                Image(assetImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.width, height: self.height)
                    .onAppear {
                    
                        Task {
                            if let cachedItem = altTextCache.getItem(byImageUrl: assetImageName) {
                                if (cachedItem.shortImageCaption != nil) {
                                    altText = cachedItem.shortImageCaption!
                                }
                            } else {
                                print("saved file")
                                altTextCache.save([URLDataModel(imageUrl: assetImageName, imageType: "asset")])
                                print("saved file count:: \(altTextCache.cachedData.count)")
                            }
                        }
                    }
                    .onTapGesture {
                        print("tapped..")
                        print("accessibility text:: \(altText)")
                    }
                    .accessibilityLabel(Text(altText))
            }
        }.onChange(of: altTextCache.cachedData) { _ in
            updateAltText()
        }
        
    }
    
    private func updateAltText() {
        if let urlString = imageUrl, let cachedItem = altTextCache.getItem(byImageUrl: urlString) {
            altText = cachedItem.shortImageCaption ?? "No Image Description"
        }
        if let assetString = assetImageName, let cachedItem = altTextCache.getItem(byImageUrl: assetString) {
            altText = cachedItem.shortImageCaption ?? "No Image Description"
        }
    }
}

