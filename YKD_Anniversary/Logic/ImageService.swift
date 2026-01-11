//
//  ImageService.swift
//  YKD_Anniversary
//
//  Created by 鍵本大地 on 2026/01/06.
//
import UIKit

final class ImageService {

    static func save(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return nil
        }

        let fileName = "icon_\(UUID().uuidString).jpg"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("画像保存失敗: \(error)")
            return nil
        }
    }

    static func loadImage(from urlString: String?) -> UIImage? {
        guard
            let urlString,
            let url = URL(string: urlString),
            FileManager.default.fileExists(atPath: url.path)
        else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }

    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
    }
    
    static func delete(url: String?) {
        guard
            let url,
            let fileURL = URL(string: url)
        else { return }

        try? FileManager.default.removeItem(at: fileURL)
    }

}

