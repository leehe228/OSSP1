//
//  DataManager.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 6/11/24.
//

import SwiftUI
import Foundation

final class DataManager {
    // Static Class로 사용
    static let shared = DataManager()
    
    // 현재 토큰 정보를 반환합니다
    static func all() -> RequestData? {
        print("load data")
        
        guard let deviceToken = UserDefaults.standard.string(forKey: "DEVICE_TOKEN") else { return nil }
        let requestID = UserDefaults.standard.integer(forKey: "REQUEST_ID")
        let imageNum = UserDefaults.standard.integer(forKey: "REQUEST_IMAGE_NUM")
        guard let time = UserDefaults.standard.object(forKey: "REQUEST_TIME") as? Date else { return nil }
        
        print("search \(imageNum) images...")
        
        var count = 0
        var imageList: [UIImage] = []
        for _ in (0..<imageNum) {
            guard let imageData = UserDefaults.standard.data(forKey: "REQUEST_IMAGE\(count)") else { return nil }
            guard let image: UIImage = UIImage(data: imageData) else { return nil }
            imageList.append(image)
            count = count + 1
        }
        
        print("data found with \(count) image")
        let requestData = RequestData(deviceToken: deviceToken, image: imageList, requestID: requestID, time: time)
        
        return requestData
    }
    
    static func getRequestID() -> Int {
        /* let id = UserDefaults.standard.integer(forKey: "STATIC_REQUEST_ID")
        UserDefaults.standard.setValue(id + 100, forKey: "STATIC_REQUEST_ID")
        return id + 100*/
        
        let now = Date()
            
        // Create a DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmss"
        
        // Convert the date to the desired string format
        let dateString = formatter.string(from: now)
        
        // Convert the string to an integer
        if let dateInt = Int(dateString) {
            return dateInt
        } else {
            // Handle the error case where the date string cannot be converted to an integer
            return 0
        }
    }
    
    // 토큰 정보를 새로 저장합니다
    // 토큰 정보를 지우려면 빈 문자열 ""를 저장하면 됩니다
    static func setToken(data: RequestData) {
        let requestID = self.getRequestID()
        
        UserDefaults.standard.setValue(data.deviceToken, forKey: "DEVICE_TOKEN")
        UserDefaults.standard.setValue(requestID, forKey: "REQUEST_ID")
        UserDefaults.standard.setValue(data.time, forKey: "REQUEST_TIME")
        
        var count = 0
        for image in data.image {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                UserDefaults.standard.set(imageData, forKey: "REQUEST_IMAGE\(count)")
                count = count + 1
            }
        }
        
        UserDefaults.standard.setValue(data.image.count, forKey: "REQUEST_IMAGE_NUM")
        
        print("data is saved with \(count) images")
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: "DEVICE_TOKEN")
        UserDefaults.standard.removeObject(forKey: "REQUEST_ID")
        UserDefaults.standard.removeObject(forKey: "REQUEST_IMAGE")
        print("all data is removed successfully")
    }
}

struct RequestData: Hashable {
    let deviceToken: String
    let image: [UIImage]
    let requestID: Int
    let time: Date
}
