//
//  RootViewModel.swift
//  dental-cavity-detector
//
//  Created by Hoeun Lee on 5/21/24.
//

import SwiftUI
import Foundation
import Combine

class RootViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    @Published var data: RequestData?
    @Published var isLoading: Bool = true
    @Published var timerCancellable: Cancellable?
    
    @Published var successResponse: SuccessResponse?
    @Published var errorResponse: ErrorResponse?
    @Published var errorMessage: String?

    func transition(_ to: ViewState) {
        DispatchQueue.main.async {
            withAnimation(.spring) {
                self.viewState = to
            }
        }
    }
    
    func loadingStart() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    func loadingDone() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    func uploadImages(_ images: [UIImage], completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // self.data = DataManager.all()
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        let tokenID = UIDevice.current.deviceToken;
        let rid = DataManager.getRequestID() //self.getCurrentDateAsInteger()
        
        let parameters = [
            [
                "key": "device_token",
                "value": tokenID,
                "type": "text"
            ],
            [
                "key": "request_id",
                "value": "\(rid)",
                "type": "text"
            ]
        ] as [[String: Any]]
        
        print("token id: " + tokenID)
        print("req id: \(rid)")
        
        let data = RequestData(deviceToken: UIDevice.current.deviceToken, image: images, requestID: rid, time: Date())
        DataManager.setToken(data: data)
        self.data = data
        
        for param in parameters {
            if param["disabled"] != nil { continue }
            let paramName = param["key"]!
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".utf8)
            let paramValue = param["value"] as! String
            body += Data("\(paramValue)\r\n".utf8)
        }
        
        for (index, image) in images.enumerated() {
            let imageData = image.jpegData(compressionQuality: 0.8)!
            let filename = "image\(index + 1).jpg"
            let mimetype = "image/jpeg"
            
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".utf8)
            body += Data("Content-Type: \(mimetype)\r\n\r\n".utf8)
            body += imageData
            body += Data("\r\n".utf8)
        }
        
        body += Data("--\(boundary)--\r\n".utf8)
        
        var request = URLRequest(url: URL(string: "http://117.16.136.174:9000/request")!, timeoutInterval: Double.infinity)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                completion(.failure(error))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                let error = NSError(domain: "InvalidData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                DataManager.reset()
                completion(.failure(error))
                return
            }
            
            self.transition(.progress)
            completion(.success(responseString))
        }
        
        task.resume()
    }
    
    func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.checkServerData(dummy: false)
            }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
    }
    
    func checkServerData(dummy: Bool=true) {
        /* if dummy {
            // guard let data = self.data else { return }
            guard let url = URL(string: "http://117.16.136.174:9090/result?device_token=tokentokentokentokentokentoken&request_id=1") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url, timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                    self.dataLoaded()
                }
            }
            
            task.resume()
        } else {
            // guard let data = self.data else { return }
            guard let data = DataManager.all() else { return }
            guard let url = URL(string: "http://117.16.136.174:9090/result?device_token= + " + data.deviceToken + "&request_id=\(data.requestID)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url, timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                    self.dataLoaded()
                }
            }
            
            task.resume()
        }*/
        
        // guard let data = DataManager.all() else { return }
        guard let data = self.data else { return }
        
        // let urlString = "http://117.16.136.174:9090/result?device_token=tokentokentokentokentokentoken&request_id=1"
        let urlString = "http://117.16.136.174:9000/result?device_token=" + data.deviceToken + "&request_id=\(data.requestID)"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Unknown error"
                }
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let successResponse = try JSONDecoder().decode(SuccessResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.successResponse = successResponse
                        print(self.successResponse)
                        
                        if successResponse.code == 1000 {
                            self.dataLoaded()
                        }
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.errorResponse = errorResponse
                        print(self.errorResponse)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print(self.errorMessage)
                }
            }
        }
        
        task.resume()
    }
    
    func dataLoaded() {
        self.stopTimer()
        self.transition(.result)
    }

    /* func getCurrentDateAsInteger() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        let second = calendar.component(.second, from: currentDate)
        
        let dateString = String(format: "%04d%02d%02d%02d%02d%02d", year, month, day, hour, minute, second)
        return Int(dateString) ?? 0
    }*/
    
    func fetchData() {
        // guard let data = DataManager.all() else { return }
        // guard let data = self.data else { return }
        
        return
        
        guard let image = UIImage(named: "dummy") else { return }
        let data = RequestData(deviceToken: "B1FFF20A-952C-4841-A3D5-318D3F23E978", image: [image], requestID: 300, time: Date())
        DataManager.setToken(data: data)
        self.data = data
        
        // let urlString = "http://117.16.136.174:9090/result?device_token=tokentokentokentokentokentoken&request_id=1"
        let urlString = "http://117.16.136.174:9000/result?device_token=BF2FE35B-CD5A-46D7-98E7-8669885687EE&request_id=1000"
        
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Unknown error"
                }
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let successResponse = try JSONDecoder().decode(SuccessResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.successResponse = successResponse
                        print(self.successResponse)
                        
                        if successResponse.code == 1000 {
                            self.dataLoaded()
                        }
                    }
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.errorResponse = errorResponse
                        print(self.errorResponse)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    print(self.errorMessage)
                }
            }
        }
        
        task.resume()
    }
}

enum ViewState {
    case home
    case progress
    case result
    case loading
}

struct Prediction: Hashable, Codable, Identifiable {
    let id = UUID()
    let cls: String
    let prob: Double
    let bbox: [[CGFloat]]
}

struct APIResult: Codable, Identifiable {
    let id = UUID()
    let pred: [Prediction]
}

struct SuccessResponse: Codable {
    let code: Int
    let status: Int
    let message: String
    let result: APIResult
}

struct ErrorResponse: Codable {
    let code: Int
    let status: Int
    let message: String
    let timestamp: String
}
