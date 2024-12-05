import os
import shutil
import random

# Paths to test train split
dataset_dir = r"C:\Users\bheja\OneDrive\Desktop\Person\dataset"
train_dir = r"C:\Users\bheja\OneDrive\Desktop\Person\train"
test_dir = r"C:\Users\bheja\OneDrive\Desktop\Person\test"

# Create directories if they do not exist
os.makedirs(os.path.join(train_dir, 'images'), exist_ok=True)
os.makedirs(os.path.join(train_dir, 'labels'), exist_ok=True)
os.makedirs(os.path.join(test_dir, 'images'), exist_ok=True)
os.makedirs(os.path.join(test_dir, 'labels'), exist_ok=True)

# Get all image files and corresponding label files
images_path = os.path.join(dataset_dir, 'images')
labels_path = os.path.join(dataset_dir, 'labels')
images = [f for f in os.listdir(images_path) if f.endswith('.jpg') or f.endswith('.png')]
labels = [f.replace('.jpg', '.txt').replace('.png', '.txt') for f in images]

# Shuffle images and split into train and test (80:20)
data = list(zip(images, labels))
random.shuffle(data)
split_index = int(len(data) * 0.8)
train_data, test_data = data[:split_index], data[split_index:]

# Copy files to train and test directories
for image, label in train_data:
    shutil.copy(os.path.join(images_path, image), os.path.join(train_dir, 'images', image))
    shutil.copy(os.path.join(labels_path, label), os.path.join(train_dir, 'labels', label))

for image, label in test_data:
    shutil.copy(os.path.join(images_path, image), os.path.join(test_dir, 'images', image))
    shutil.copy(os.path.join(labels_path, label), os.path.join(test_dir, 'labels', label))
