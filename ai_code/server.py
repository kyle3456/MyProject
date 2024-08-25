import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
import torch
from PIL import Image
from io import BytesIO

app = Flask(__name__)
CORS(app)

# Load the model
model_path = 'model.pt'
model = YOLO(model_path)

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'})
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'})
    
    try:
        # Load the image
        img = Image.open(BytesIO(file.read()))

        # Make the prediction
        results = model(img)

        # Return the results
        predictions = results[0].boxes

        response = {
            "predictions": []
        }

        for pred in predictions:
            response["predictions"].append({
                "class": model.names[int(pred.cls)],
                "confidence": float(pred.conf)
            })

        return jsonify(response), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2500)