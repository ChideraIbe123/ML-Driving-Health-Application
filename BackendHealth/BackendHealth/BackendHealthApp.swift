//
//  BackendHealthApp.swift
//  BackendHealth
//
//  Created by Carlos Paredes on 6/12/24.
//

import SwiftUI
import SwiftData
import HealthKit
@main
struct BackendHealthApp: App {
    //    var sharedModelContainer: ModelContainer = {
    //        let schema = Schema([
    //            Item.self,
    //        ])
    //        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    //
    //        do {
    //            return try ModelContainer(for: schema, configurations: [modelConfiguration])
    //        } catch {
    //            fatalError("Could not create ModelContainer: \(error)")
    //        }
    //    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(){
                    HealthKitManager.shared.requestAuthorization { (success, error) in
                        if success {
                            let healthData = loadHealthDataFromCSV()
                            HealthKitManager.shared.saveHealthDataToHealthKit(healthDataArray : healthData)
                        } else {
                            print("HealthKit authorization failed: \(String(describing: error))")
                        }
                    }
                }
//            let viewCntrl = ViewController()
//            let hostCntrl = UIHostingController(rootView: ContentView())
//            viewCntrl.addChild(hostCntrl)
//            viewCntrl.view.addSubview(hostCntrl.view)
//            hostCntrl.view.frame = viewCntrl.view.bounds
//            hostCntrl.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
//            hostCntrl.didMove(toParent: viewCntrl)
//            UIApplication.shared.windows.first?.rootViewController = viewCntrl
//            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}

struct HealthData : Codable{
    let id: Int
    let date: Date
    let steps: Int
    let caloriesBurned: Double
    let o2Sat: Double
    let heartRate: Int
}

func loadHealthDataFromCSV() -> [HealthData] {
//    guard let url = Bundle.main.url(forResource: "Car_Health_Metrics_Dataset", withExtension: "csv") else {
//        fatalError("dummyHealthData.csv not found")
//    }
    let url = URL(string:"file:///Users/vadd9h/Documents/Hackday24/BackendHealth/BackendHealth/Car_Health_Metrics_Dataset.csv")!
    do {
        let data = try String(contentsOf: url)
        var healthDataArray: [HealthData] = []
       
        let rows = data.split(separator: "\n").dropFirst() // Skip header row
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
       
        for (index, row) in rows.enumerated() {
            let columns = row.split(separator: ",")
            if columns.count == 2,
               let o2Sat = Double(columns[0]),
               let heartRate = Int(columns[1]) {
                let healthData = HealthData(
                    id: index + 1,
                    date: dateFormatter.date(from: "2023/06/12 08:00")!.addingTimeInterval(TimeInterval(3600 * index)),
                    steps: Int.random(in:  1000 ... 10000),
                    caloriesBurned: Double.random(in: 50.0 ... 500),
                    o2Sat: o2Sat,
                    heartRate: heartRate
                )
                healthDataArray.append(healthData)
            }
        }
        print(healthDataArray)
        return healthDataArray
    } catch {
        fatalError("Error reading dummyHealthData.csv: \(error)")
    }
}
