//
//  URLDataModel.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//

import Foundation

// Model yapısı
public struct URLDataModel: Codable, @unchecked Sendable, Equatable {
    let imageUrl: String
    var shortImageCaption: String?
    var longImageCaption: String?
    var imageType: String?

    public init(imageUrl: String, shortImageCaption: String? = nil, longImageCaption: String? = nil, imageType: String? = nil) {
        self.imageUrl = imageUrl
        self.shortImageCaption = shortImageCaption
        self.longImageCaption = longImageCaption
        self.imageType = imageType
    }
    
    // Equatable Protokolü için eşitlik karşılaştırması
    public static func == (lhs: URLDataModel, rhs: URLDataModel) -> Bool {
        return lhs.imageUrl == rhs.imageUrl &&
                lhs.shortImageCaption == rhs.shortImageCaption &&
                lhs.longImageCaption == rhs.longImageCaption &&
                lhs.imageType == rhs.imageType
    }

    // CopyWith benzeri bir fonksiyon
    public func copyWith(
        imageUrl: String? = nil,
        shortImageCaption: String? = nil,
        longImageCaption: String? = nil,
        imageType: String? = nil
    ) -> URLDataModel {
        return URLDataModel(
            imageUrl: imageUrl ?? self.imageUrl,
            shortImageCaption: shortImageCaption ?? self.shortImageCaption,
            longImageCaption: longImageCaption ?? self.longImageCaption,
            imageType: imageType ?? self.imageType
        )
    }
}
