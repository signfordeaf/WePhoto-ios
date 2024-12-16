//
//  ApiService.swift
//  WePhoto
//
//  Created by Selim Yavaşoğlu on 22.11.2024.
//

import Foundation
import UIKit

@available(iOS 14.0, *)
public struct ApiService {
    private let baseURL: URL = URL(string: "https://pl.weaccess.ai/mobile/api/") ?? URL(fileURLWithPath: "")

    @MainActor public func getImageDescriptionURL(
            imagePath: String,
            dest: String = "en",
            completion: @escaping @Sendable (Result<(String, String), Error>) -> Void
        ) {
            let parameters = [
                ["key": "create_types", "value": "[\"alt\",\"desc\"]"],
                ["key": "image_url", "value": imagePath],
                ["key": "lang", "value": dest],
                ["key": "api_key", "value": WePhotoInit.shared?.apiKey ?? ""]
            ]

            let boundary = "Boundary-\(UUID().uuidString)"
            var body = Data()

            for param in parameters {
                guard let paramName = param["key"], let paramValue = param["value"] else { continue }

                body += "--\(boundary)\r\n".data(using: .utf8)!
                body += "Content-Disposition: form-data; name=\"\(paramName)\"\r\n".data(using: .utf8)!
                body += "\r\n".data(using: .utf8)!
                body += "\(paramValue)\r\n".data(using: .utf8)!
            }

            body += "--\(boundary)--\r\n".data(using: .utf8)!
            
            
            var request = URLRequest(url: URL(string: "\(baseURL)wephoto-create/")!, timeoutInterval: 60)
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = body

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                    return
                }
                switch httpResponse.statusCode {
                case 200...204:
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let altText = json["image_alt_text"] as? String ?? "No Image Caption available"
                            let desc = json["image_desc"] as? String ?? "No Image Caption available"

                            if altText == "Gateway error" || desc == "Gateway error" {
                                completion(.success(("No Image Caption available", "No Image Caption available")))
                            } else {
                                completion(.success((altText, desc)))
                            }
                        } else {
                            completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                case 400, 401, 403, 404, 500:
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                default:
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                }
            }
            task.resume()
        }
    
    @MainActor public func getImageDescriptionFile(
        imageAsset: String,
        dest: String = "en",
        completion: @escaping @Sendable (Result<(String, String), Error>) -> Void
    ) {
        
        guard let image = UIImage(named: imageAsset) else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let parameters = [
            [
                        "key": "create_types",
                        "value": "[\"alt\",\"desc\"]",
                        "type": "text"
                    ],
                    [
                        "key": "file",
                        "src": imageData,
                        "type": "file"
                    ],
                    [
                        "key": "lang",
                        "value": dest,
                        "type": "text"
                    ],
                    [
                        "key": "api_key",
                        "value": WePhotoInit.shared?.apiKey ?? "",
                        "type": "text"
                    ]
        ]

        let boundary = "Boundary-\(UUID().uuidString)"
           var body = Data()

           // Parametreleri ekle
           for param in parameters {
               if param["disabled"] != nil { continue }

               let paramName = param["key"]!
               body += Data("--\(boundary)\r\n".utf8)
               body += Data("Content-Disposition:form-data; name=\"\(paramName)\"".utf8)

               // Eğer contentType varsa, başlık ekle
               if let contentType = param["contentType"] as? String {
                   body += Data("\r\nContent-Type: \(contentType)\r\n".utf8)
               }

               // Parametrenin tipine göre işle
               let paramType = param["type"] as! String
               if paramType == "text" {
                   let paramValue = param["value"] as! String
                   body += Data("\r\n\r\n\(paramValue)\r\n".utf8)
               } else if paramType == "file" {
                   // Dosya parametresi
                   let imageData = image.jpegData(compressionQuality: 1.0)  // Resmi JPEG formatında veriye dönüştür
                   if let imageData = imageData {
                       body += Data("; filename=\"image.jpg\"\r\n".utf8)
                       body += Data("Content-Type: image/jpeg\r\n".utf8)  // MIME type olarak image/jpeg kullan
                       body += Data("\r\n".utf8)
                       body += imageData
                       body += Data("\r\n".utf8)
                   }
               }
           }

           // Son boundary'yi ekle
           body += Data("--\(boundary)--\r\n".utf8)

           // POST verisini hazırla
           let postData = body

           // URLRequest oluştur
        var request = URLRequest(url: URL(string: "\(baseURL)wephoto-create/")!, timeoutInterval: .infinity)
           request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
           request.httpMethod = "POST"
           request.httpBody = postData
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Error:: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error:: Invalid JSON 0")
                completion(.failure(NSError(domain: "Invalid Response", code: -1, userInfo: nil)))
                
                return
            }

            guard let data = data else {
                print("Error:: No Data")
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            switch httpResponse.statusCode {
            case 200...204:
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let altText = json["image_alt_text"] as? String ?? "No Image Caption available"
                        let desc = json["image_desc"] as? String ?? "No Image Caption available"

                        if altText == "Gateway error" || desc == "Gateway error" {
                            print("Error Gateway")
                            completion(.success(("No Image Caption available", "No Image Caption available")))
                        } else {
                            print("alt text:: \(altText), desc:: \(desc)")
                            completion(.success((altText, desc)))
                        }
                    } else {
                        completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
                        print("Error:: Invalid JSON -1")
                    }
                } catch {
                    completion(.failure(error))
                    print("Error:: \(error.localizedDescription)")
                }
            case 400, 401, 403, 404, 500:
                if let error = error {
                    completion(.failure(error))
                    print("Error:: \(error.localizedDescription)")
                    return
                }
            default:
                if let error = error {
                    completion(.failure(error))
                    print("Error:: \(error.localizedDescription)")
                    return
                }
            }
        }
        task.resume()
    }
    
    
    public func dispose() {
        // Dispose işlemleri
    }
}
