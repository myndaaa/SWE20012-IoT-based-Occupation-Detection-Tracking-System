from ultralytics import YOLO

# Load model
model = YOLO('yolov8n.pt')  # Loading YOLOv8 nano version, which is lightweight

# Train model
model.train(data='C:/Users/bheja/OneDrive/Desktop/Person/data.yaml', epochs=100, imgsz=640, batch=8)
