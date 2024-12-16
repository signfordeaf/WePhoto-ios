//
//  VisualRepresentationService.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//

import Foundation
import SwiftUICore


@available(iOS 14.0, *)
class VisualRepresentationService: @unchecked Sendable {
    @MainActor public static let shared = VisualRepresentationService()
    
    private var cacheBox = URLDataCache.shared
    let apiService: ApiService = ApiService()
    
       // Timer nesnesi
    private var timer: Timer?
    // Timer'ın çalışma aralığı (varsayılan önce 3 - sonra 60 saniye)
    private var interval: TimeInterval = 5
    // Private init (Singleton olduğu için)
    private init() {}
    /// Timer'ı başlatan fonksiyon
    public func startTimer(withInterval interval: TimeInterval? = nil) {
        // Eğer bir interval belirtilmişse, mevcut interval'i güncelle
        if let newInterval = interval {
            self.interval = newInterval
        }
        // Önceki Timer'ı durdur (eğer varsa)
        stopTimer()
        // Yeni Timer'ı başlat
        timer = Timer.scheduledTimer(
            timeInterval: self.interval,
            target: self,
            selector: #selector(startTimerFunc),
            userInfo: nil,
            repeats: true
        )
    }
    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    /// Timer çalıştığında çağrılacak fonksiyon
    @MainActor @objc private func startTimerFunc() {
        interval = 60
        findNullImageDescriptions()
    }
    
    @MainActor private func findNullImageDescriptions() {
        print("data count:: \(cacheBox.cachedData.count)")
        cacheBox.cachedData.forEach { cachedItem in
            if (cachedItem.shortImageCaption == nil ||
                cachedItem.longImageCaption == nil ||
                cachedItem.shortImageCaption == "No Image Caption available" ||
                cachedItem.longImageCaption == "No Image Caption available") {
                print("Bulunmayan İtem: \(cachedItem.imageUrl)")
                if (cachedItem.imageType == "url") {
                    apiService.getImageDescriptionURL(imagePath: cachedItem.imageUrl) { result in
                        switch result {
                        case .success((let text1, let text2)):
                            let updatedItem = cachedItem.copyWith(
                                imageUrl: cachedItem.imageUrl,
                                shortImageCaption: text1,
                                longImageCaption: text2
                            )
                            DispatchQueue.main.async {
                                self.cacheBox.save([updatedItem])
                            }
                        case .failure(_):
                            return
                        }
                    }
                } else if (cachedItem.imageType == "asset") {
                    apiService.getImageDescriptionFile(imageAsset: cachedItem.imageUrl) { result in
                        switch result {
                        case .success((let text1, let text2)):
                            let updatedItem = cachedItem.copyWith(
                                imageUrl: cachedItem.imageUrl,
                                shortImageCaption: text1,
                                longImageCaption: text2
                            )
                            DispatchQueue.main.async {
                                self.cacheBox.save([updatedItem])
                            }
                        case .failure(_):
                            return
                        }
                    }
                }
            } else {
                print("Tüm İtemler: \(cachedItem.imageUrl)")
                print("Short Desc: \(String(describing: cachedItem.shortImageCaption))")
                print("Long Desc: \(String(describing: cachedItem.longImageCaption))")
                return
            }
        }
    }
}
