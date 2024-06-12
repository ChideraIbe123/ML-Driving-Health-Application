import HealthKit
import Foundation
class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            // Add more types as needed
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    func fetchBiometricsData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        var biometricsData: [String: Any] = [:]
        
        let dispatchGroup = DispatchGroup()
        
        // Fetch weight
//        dispatchGroup.enter()
//        fetchMostRecentSample(for: HKObjectType.quantityType(forIdentifier: .bodyMass)!) { (sample, error) in
//            if let sample = sample as? HKQuantitySample {
//                biometricsData["weight"] = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
//            }
//            dispatchGroup.leave()
//        }
//        
        // Fetch O2 Sat
        dispatchGroup.enter()
        fetchMostRecentSample(for: HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!) { (sample, error) in
            if let sample = sample as? HKQuantitySample {
                biometricsData["height"] = sample.quantity.doubleValue(for: .percent())
            }
            dispatchGroup.leave()
        }
        
        // Fetch heart rate
        dispatchGroup.enter()
        fetchMostRecentSample(for: HKObjectType.quantityType(forIdentifier: .heartRate)!) { (sample, error) in
            if let sample = sample as? HKQuantitySample {
                biometricsData["heartRate"] = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
            }
            dispatchGroup.leave()
        }
        
        // Notify completion
        dispatchGroup.notify(queue: .main) {
            completion(biometricsData, nil)
        }
    }
    
    private func fetchMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKSample?, Error?) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            completion(samples?.first, error)
        }
        
        healthStore.execute(query)
    }
    func saveHealthDataToHealthKit(healthDataArray: [HealthData]) {
            guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate),
                  let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {
                fatalError("HealthKit types are no longer available")
            }
           
            var healthKitSamples: [HKSample] = []
            let now = Date()
           
            for (index, data) in healthDataArray.enumerated() {
                let sampleDate = now.addingTimeInterval(TimeInterval(60 * index)) // 1-minute interval
               
                // Heart Rate Sample
                let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(data.heartRate))
                let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: sampleDate, end: sampleDate)
                healthKitSamples.append(heartRateSample)
               
                // Oxygen Saturation Sample
                let oxygenSaturationQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: data.o2Sat / 100.0)
                let oxygenSaturationSample = HKQuantitySample(type: oxygenSaturationType, quantity: oxygenSaturationQuantity, start: sampleDate, end: sampleDate)
                healthKitSamples.append(oxygenSaturationSample)
            }
           
            // Save samples to HealthKit
            healthStore.save(healthKitSamples) { (success, error) in
                if success {
                    print("Successfully saved samples to HealthKit")
                } else {
                    print("Failed to save samples: \(String(describing: error))")
                }
            }
        }
}
/// Data Prep

class DataPreparation {
    func prepareDataForRegression(biometricsData: [String: Any]) -> String {
        var csvString = "O2Sat,HeartRate\n"
        
        if let O2Sat = biometricsData["O2Sat"],
           let heartRate = biometricsData["heartRate"] {
            csvString +=  "\(O2Sat),\(heartRate)\n"
        }
        
        return csvString
    }
    
    func saveCSVToFile(csvString: String, filename: String) -> URL? {
//        let fileManager = FileManager.default
//        let tempDirectory = fileManager.temporaryDirectory
//        let fileURL = tempDirectory.appendingPathComponent(filename).appendingPathExtension("csv")
        guard let curdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failure")
            return nil
        }
        let fileURL = curdir.appendingPathComponent(filename).appendingPathExtension("csv")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
}
