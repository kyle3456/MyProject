from ultralytics import YOLO
import torch
import torchvision

def train():
    data_config_path = 'data.yaml'
    model_save_path = 'model.pt'

    model = YOLO('yolov8n.pt')
    model.train(data=data_config_path, epochs=50, batch=16, imgsz=640, device='mps')

    results = model.val(data=data_config_path, device='mps')
    metrics = results.results_dict

    accuracy = metrics['metrics/precision(B)']  # Adjust to the correct metric key if needed
    print(f'Validation Precision: {accuracy * 100:.2f}%')

    model.save(model_save_path)

if __name__ == '__main__':
    train()