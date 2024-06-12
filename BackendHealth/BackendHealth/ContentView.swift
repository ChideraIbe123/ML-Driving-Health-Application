//
//  ContentView.swift
//  BackendHealth
//
//  Created by Carlos Paredes on 6/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext;
    @Query private var items: [Item];
    @State private var authstat = "Requesting info";
    @State private var biometricdata: [String: Any] = [:];
    
    var body: some View {
        VStack{
            Text(authstat)
                .padding()
            if  let O2Sat = biometricdata["O2Sat"] as? Double,
                let heartRate = biometricdata["heartRate"] as? Double{
                Text("Heart Rate : \(heartRate) bpm")
                Text("Heart Rate : \(O2Sat) %")
            }
        }
        Button("Fetch Data") {
            fetchAndPrepareData()
        }
        .padding()
        .onAppear(){
            HealthKitManager.shared.requestAuthorization { (success, error) in
                if success {
                    self.fetchAndPrepareData()
                } else {
                    print("HealthKit authorization failed: \(String(describing: error))")
                }
            }
        }
    }
func fetchAndPrepareData() {
        HealthKitManager.shared.fetchBiometricsData { (data, error) in
            if let data = data {
                let dataPreparation = DataPreparation()
                let csvString = dataPreparation.prepareDataForRegression(biometricsData: data)
                if let fileURL = dataPreparation.saveCSVToFile(csvString: csvString, filename: "biometrics") {
                    print("CSV file saved at: \(fileURL)")
                    // Use the fileURL to transfer the file for regression
                }
            } else {
                print("Error fetching biometrics data: \(String(describing: error))")
            }
        }
    }
    struct ContentView_Previews: PreviewProvider{
        static var previews: some View{
            ContentView()
        }
    }
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
    

//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
