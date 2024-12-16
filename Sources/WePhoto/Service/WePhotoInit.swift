//
//  WePhotoInit.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//
@available(iOS 14.0, *)
@MainActor
public final class WePhotoInit {
    
    // Statik olarak global erişim için paylaşılan bir özellik
   public static var shared: WePhotoInit?
    
    // API Key özelliği
    public private(set) var apiKey: String?
    
    public init(apiKey: String!) {
        self.apiKey = apiKey
        Self.shared = self // Statik özelliği ayarla
        VisualRepresentationService.shared.startTimer()
    }
    
    public func setApiKey(_ key: String) {
        self.apiKey = key
    }
}
