import Foundation

class DataPreparation {
    func prepareDataForRegression(biometricsData: [String: Any]) -> String {
        var csvString = "Weight,Height,HeartRate\n"
        
        if let weight = biometricsData["weight"],
           let height = biometricsData["height"],
           let heartRate = biometricsData["heartRate"] {
            csvString += "\(weight),\(height),\(heartRate)\n"
        }
        
        return csvString
    }
    
    func saveCSVToFile(csvString: String, filename: String) -> URL? {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename).appendingPathExtension("csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
}
