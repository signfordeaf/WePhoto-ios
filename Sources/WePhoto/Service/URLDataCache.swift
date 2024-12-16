//
//  URLDataCache.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 25.11.2024.
//

import Foundation

class URLDataCache : ObservableObject {
    nonisolated(unsafe) static let shared = URLDataCache()
    private let userDefaultsKey = "URLDataCacheKey"
    
    private let cacheFileName = "urlDataCache.json"
    
    @Published var cachedData: [URLDataModel] = []

    private init() {
        self.cachedData = loadCache()
    }

    // Kaydetme
    func save(_ data: [URLDataModel]) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            self.cachedData = data
        }
        saveCache()
        objectWillChange.send()
    }

    // Veriyi alma
    func load() -> [URLDataModel] {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedData = try? decoder.decode([URLDataModel].self, from: savedData) {
            return decodedData
        }
        return []
    }
    
    private func saveCache() {
            do {
                let fileURL = getCacheFileURL()
                let data = try JSONEncoder().encode(cachedData)
                try data.write(to: fileURL)
            } catch {
                print("Failed to save cache: \(error)")
            }
        }
        
        private func loadCache() -> [URLDataModel] {
            do {
                let fileURL = getCacheFileURL()
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode([URLDataModel].self, from: data)
            } catch {
                print("Failed to load cache: \(error)")
            }
            return []
        }
    
    private func getCacheFileURL() -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return documentsDirectory.appendingPathComponent(cacheFileName)
        }
    
    // İstenilen veriyi alma
    func getItem(byImageUrl imageUrl: String) -> URLDataModel? {
        return self.cachedData.first(where: { $0.imageUrl == imageUrl })
        }

    // Veriyi temizleme
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
