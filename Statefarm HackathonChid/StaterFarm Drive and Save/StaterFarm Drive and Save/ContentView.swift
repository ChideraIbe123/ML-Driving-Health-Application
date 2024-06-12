import SwiftUI

struct ContentView: View {
   @StateObject private var networkManager = NetworkManager()
   @State private var noiseLevel = ""
   @State private var bloodOxygenLevel = ""
   @State private var averageHeartRate = ""
   @State private var score = ""
   @State private var bigScore = ""
    @State private var scoreChange: Double? = nil
  
   var body: some View {
       VStack(spacing: 0) {
           // Top Header
           VStack(spacing: 10) {
               Text("StateFarm Drive and Save")
                   .font(.system(size: 16, weight: .bold, design: .serif))
                   .foregroundColor(.white)
               HStack(spacing: 80) {
                   Text("# of trips")
                       .font(.system(size: 13, weight: .heavy, design: .serif))
                       .foregroundColor(.white)
                   Text(bigScore)
                       .font(.system(size: 40, weight: .heavy, design: .serif))
                       .foregroundColor(.white)
                   Text("# miles")
                       .font(.system(size: 13, weight: .heavy, design: .serif))
                       .foregroundColor(.white)
               }
               Text("2 Week Duration")
                   .font(.system(size: 13, weight: .bold, design: .serif))
                   .foregroundColor(.white)
           }
           .frame(maxWidth: .infinity)
           .frame(height: UIScreen.main.bounds.height / 8) // Adjusted height for the top header
           .padding()
           .background(Color.red)
           .onAppear(perform: loadData)
         
          
           // Main Content
           ScrollView {
               VStack(spacing: 20) { // Less space between the boxes
                   CustomTextBox(title: "Noise Level", text: $noiseLevel)
                   CustomTextBox(title: "Blood Oxygen Level", text: $bloodOxygenLevel)
                   Image("map") // Use the name of the image added to the assets
                                          .resizable()
                                          .scaledToFill()
                                          .frame(maxWidth: .infinity)
                                          .frame(height: 250) // Match the height of the text boxes
                                          .cornerRadius(15)
                                          .shadow(radius: 5)
                                          .border(Color.black)
                   CustomTextBox(title: "Average Heart Rate", text: $averageHeartRate)
                   CustomTextBox(title: "Score", text: .constant(scoreMessage))
                   
               }
               .padding()
                          }
           .background(Color.white)
           .cornerRadius(15)
           .border(Color.black)
          
           // Bottom Header
           HStack {
               Spacer()
               Image(systemName: "house.fill")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(width: 30, height: 30) // Smaller icon size
               Spacer()
           }
           .padding()
           .frame(height: 80) // Keep the increased height for bottom header
           .background(Color.gray)
       }
       .edgesIgnoringSafeArea(.bottom)
   }
    var scoreMessage: String {
            if let scoreInt = Int(bigScore) {
                if scoreInt > 80 {
                    return "Your score is above the average for users, keep up the great work and look at the other boxes for futher feedback"
                } else if scoreInt == 80 {
                    return "Your score is average for users, please look at the other boxes for futheer tips to improve driver health and safety"
                } else {
                    return "Your score is below the average for users, we strongly advisee you look at the other boxes for futher tips to improve driver health and safety"
                }
            }
            return ""
        }
    
    func loadData() {
        // Fetch noise level
        networkManager.fetchFeedback(inputValue: 0, metric: "noiseLevel") { feedback in
            self.noiseLevel = feedback
            print("Noise Level: \(feedback)")
        }
        // Fetch blood oxygen level
        networkManager.fetchFeedback(inputValue: 0, metric: "bloodOxygen") { feedback in
            self.bloodOxygenLevel = feedback
            print("Blood Oxygen Level: \(feedback)")
            
        }
        // Fetch average heart rate
        networkManager.fetchFeedback(inputValue: 0, metric: "heartRate") { feedback in
            self.averageHeartRate = feedback
            print("Average Heart Rate: \(feedback)")
        }
        networkManager.fetchPrediction(method: "GET" ,heartRate: 70, bloodOxygenLevel: 95, noiseLevel: 60) { prediction in
//            self.bigScore = "t"
            var temp : String = " "
            switch prediction {
                        case .success(let json):
                            print("Dictionary JSON Response: \(json)")
                            // Extract value from dictionary if needed
                
                        if let value = json["prediction"] as? Int {
                            print("Extracted Value: \(value)")
                            temp = "\(value)"
                        }
                        default:
                            print("wrong")
                
            }
            self.bigScore = temp
//           print(prediction.split(separator: ":"))
            print(self.bigScore)
            print("Prediction: \(prediction)")
        }
        func fetchScoreChange() {
                networkManager.fetchScoreChange { change in
                    self.scoreChange = change
                }
            }
        
   
    }
}


struct CustomTextBox: View {
    var title: String
    @Binding var text: String
  
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Adjust spacing for better appearance
            Text(title)
                .font(.system(size: 25, weight: .bold))
            Text(text) // Use Text view to display multi-line text
                .font(.system(size: 20)) // Increase font size for better appearance
                .frame(maxWidth: .infinity, alignment: .leading) // Make sure text is left-aligned
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
        .border(Color.black)
    }
}

struct OtherCustomTextBox: View {
    var title: String
    @Binding var text: String
    @Binding var scoreChange: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Adjust spacing for better appearance
            Text(title)
                .font(.system(size: 25, weight: .bold))
            Text(text) // Use Text view to display multi-line text
                .font(.system(size: 20)) // Increase font size for better appearance
                .frame(maxWidth: .infinity, alignment: .leading) // Make sure text is left-aligned
            
            if let change = scoreChange {
                HStack {
                    Text("\(String(format: "%.2f", change))%")
                        .foregroundColor(change >= 0 ? .green : .red)
                    Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                        .foregroundColor(change >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
        .border(Color.black)
    }
}

struct CustomTextBoxWithImage: View {
    var title: String
    var text: String
    var imageName: String
  
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) { // Adjust spacing for better appearance
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                Text(text) // Use Text view to display multi-line text
                    .font(.system(size: 15)) // Increase font size for better appearance
                    .frame(maxWidth: .infinity, alignment: .leading) // Make sure text is left-aligned
            }
            
          
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Adjust the size as needed
                .cornerRadius(15)
                .shadow(radius: 5)
                
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
        .border(Color.black)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
