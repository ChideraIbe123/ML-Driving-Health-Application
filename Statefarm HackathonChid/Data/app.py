from flask import Flask, request, jsonify
import pandas as pd
import csv
import os
from xgboost import XGBRegressor
from sklearn.preprocessing import StandardScaler, PolynomialFeatures
from sklearn.pipeline import Pipeline
import joblib
import numpy as np


app = Flask(__name__)

last_score = None
change = None 

model = joblib.load("/Users/main/Desktop/Statefarm Hackathon/Data/driver_xgb_model.pkl")

# Sample data for demonstration purposes
sample_API_data = {
    'HeartRate': [60, 70, 80, 90, 100],
    'BloodOxygenLevel': [95, 96, 97, 98, 99],
    'NoiseLevel': [50, 55, 60, 65, 70]
}
sample_API_df = pd.DataFrame(sample_API_data)
API_data = {
    'HeartRate': [10, 10, 10, 10, 100],
    'BloodOxygenLevel': [95, 96, 97, 98, 99],
    'NoiseLevel': [50, 55, 60, 65, 70]
}
API_df = pd.DataFrame(API_data)

def avgHeartRate(input):
    input = API_df["HeartRate"].mean()
    avg_heart_rate = sample_API_df["HeartRate"].mean()
    std_heart_rate = sample_API_df["HeartRate"].std()
    
    if input < (avg_heart_rate - std_heart_rate):
        return f"Your heart rate over the past two weeks was {input:.2f} which is significantly lower than average. This may indicate an issue that should be addressed. Consider consulting a healthcare professional."
    elif input > (avg_heart_rate + std_heart_rate):
        return f"Your heart rate over the past two weeks was {input:.2f} which is significantly higher than average. This may suggest increased stress levels. Consider stress-reduction techniques or consulting a healthcare professional if this persists."
    else:
        return f"Your heart rate over the past two weeks was {input:.2f} which is within the normal range. Keep monitoring to maintain good health."

def avgBloodOxygen(input):
    input = API_df["BloodOxygenLevel"].mean()
    avg_blood_oxygen = sample_API_df["BloodOxygenLevel"].mean()
    std_blood_oxygen = sample_API_df["BloodOxygenLevel"].std()
    
    if input < (avg_blood_oxygen - std_blood_oxygen):
        return f"Your blood oxygen levels over the past two weeks was {input:.2f} which is significantly lower than average. This may indicate an issue that should be addressed. Consider consulting a healthcare professional."
    elif input > (avg_blood_oxygen + std_blood_oxygen):
        return f"Your blood oxygen levels over the past two weeks was {input:.2f} which is higher than average. This is generally not a concern, but you should ensure you are breathing comfortably and regularly."
    else:
        return f"Your blood oxygen levels over the past two weeks was {input:.2f} which is within the normal range. Keep monitoring to maintain good health."

def avgNoiseLevel(input):
    input = API_df["NoiseLevel"].mean()
    avg_noise_level = sample_API_df["NoiseLevel"].mean()
    std_noise_level = sample_API_df["NoiseLevel"].std()
    
    if input < (avg_noise_level - std_noise_level):
        return f"The noise level over the past two weeks was {input:.2f} which is significantly lower than average. This could indicate a quieter environment than usual."
    elif input > (avg_noise_level + std_noise_level):
        return f"The noise level over the past two weeks was {input:.2f} which is significantly higher than average. This may suggest a noisier environment which could affect concentration and comfort. Consider measures to reduce noise if possible."
    else:
        return f"The noise level over the past two weeks was {input:.2f} which is within the normal range. Keep monitoring to maintain a comfortable environment."

@app.route('/feedback', methods=['POST'])
def feedback():
    data = request.json
    input_value = data['input_value']
    metric = data['metric']
    
    if metric == 'heartRate':
        feedback = avgHeartRate(input_value)
    elif metric == 'bloodOxygen':
        feedback = avgBloodOxygen(input_value)
    elif metric == 'noiseLevel':
        feedback = avgNoiseLevel(input_value)
    else:
        feedback = "Invalid metric"
    
    return jsonify({'feedback': feedback})

@app.route('/predict', methods=['POST','GET'])
def predict():
    global last_score
    print("temp")
    if request.method == 'GET':
        # data = request.json
        features = np.array([[API_df["HeartRate"].mean(), API_df["BloodOxygenLevel"].mean(), API_df["NoiseLevel"].mean()]])        
        new_data_poly = model.named_steps['poly'].transform(features)
        new_data_scaled = model.named_steps['scaler'].transform(new_data_poly)
        prediction = model.named_steps['regressor'].predict(new_data_scaled)
        score = str(prediction[0])
        # return f"{score}"
        print(prediction)
        temp =  str(jsonify({'prediction': round(prediction[0])}))
        if last_score is not None:
            change = ((round(prediction[0]) - last_score) / last_score) * 100
        else:
            change = None  # No previous score to compare
    
        last_score = round(prediction[0])
        return jsonify({'prediction': round(prediction[0])})
    if request.method == 'POST':
        data = pd.DataFrame(request.json)
        for key, value in data.items():
            API_data[key].extend(value)
        return jsonify({'prediction': round(prediction[0])})

@app.route('/get_change', methods=['GET'])
def get_change():
    global change
    return jsonify({'change': change})

@app.route("/")
def hello_world():
  # Get query parameters from the URL (if any)
  name = request.args.get("name", "World")  # "name" is the parameter name, "World" is the default value
  return f"Hello, {name}!"

def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()
@app.get('/shutdown')
def shutdown():
    shutdown_server()
    return 'Server shutting down...'

if __name__ == '__main__':
    app.run(host="0.0.0.0",port=8000,debug=False)
