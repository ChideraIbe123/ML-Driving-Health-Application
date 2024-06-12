import Foundation

class NetworkManager: ObservableObject {
    @Published var noiseLevel: String = ""
    @Published var bloodOxygenLevel: String = ""
    @Published var averageHeartRate: String = ""
    @Published var prediction: String = ""
    
    func fetchFeedback(inputValue: Double, metric: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "http://localhost:8000/feedback") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "input_value": inputValue,
            "metric": metric
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(FeedbackResponse.self, from: data) {
                    DispatchQueue.main.async {
                        completion(decodedResponse.feedback)
                    }
                } else {
                    print("Failed to decode response for \(metric)")
                }
            } else {
                print("Failed to fetch \(metric): \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }
    enum FetchResult {
        case success([String: Any])
        case failure(Error)
        case successString(String)
        case invalidResponse
        case parsingError
    }
    func fetchPrediction(method: String,heartRate: Double, bloodOxygenLevel: Double, noiseLevel: Double, completion: @escaping (FetchResult) -> Void) {
//        @escaping (, Error>) -> Void)
        guard let url = URL(string: "http://localhost:8000/predict") else { return }
        
        var request = URLRequest(url: url)
        if method == "GET"{
            URLSession.shared.dataTask(with: request) { data, response, error in
                        // Check if there was an error
                // Handle the error
                       if let error = error {
                           completion(.failure(error))
                           return
                       }

                       // Validate the response
                       guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                           let responseError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                           return
                       }

                       // Ensure data is not nil
                       guard let data = data else {
                           let noDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                           return
                       }

                       // Parse the data
                       do {
                           if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                               completion(.success(json))
                           } else {
                               let parsingError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data parsing error"])
                           }
                       } catch let parseError {
                           completion(.failure(parseError))
                       }
                    
                    }.resume()
        }
        else{
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "HeartRate": heartRate,
                "BloodOxygenLevel": bloodOxygenLevel,
                "NoiseLevel": noiseLevel
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(PredictionResponse.self, from: data) {
                        DispatchQueue.main.async {
                            print("Prediction Response: \(decodedResponse.prediction)")  // Debug print
                            completion(.successString(decodedResponse.prediction))
                        }
                    } else {
                        print("Failed to decode prediction response")
                    }
                } else {
                    print("Failed to fetch prediction: \(error?.localizedDescription ?? "Unknown error")")
                }
            }.resume()
        }
    }
    func fetchScoreChange(completion: @escaping (Double?) -> Void) {
            guard let url = URL(string: "http://localhost:8000/get_change") else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Double] {
                        DispatchQueue.main.async {
                            completion(json["change"])
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else if let error = error {
                    print("Failed to fetch score change: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        }
}

struct FeedbackResponse: Codable {
    let feedback: String
}

struct PredictionResponse: Codable {
    let prediction: String
}
