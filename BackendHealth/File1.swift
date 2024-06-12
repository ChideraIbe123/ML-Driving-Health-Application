import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
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
        dispatchGroup.enter()
        fetchMostRecentSample(for: HKObjectType.quantityType(forIdentifier: .bodyMass)!) { (sample, error) in
            if let sample = sample as? HKQuantitySample {
                biometricsData["weight"] = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            }
            dispatchGroup.leave()
        }
        
        // Fetch height
        dispatchGroup.enter()
        fetchMostRecentSample(for: HKObjectType.quantityType(forIdentifier: .height)!) { (sample, error) in
            if let sample = sample as? HKQuantitySample {
                biometricsData["height"] = sample.quantity.doubleValue(for: .meterUnit(with: .centi))
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
}
