import os
import shutil
import random

def generate_label_file(image_path, class_id, label_dest_dir):
    label_file = os.path.join(label_dest_dir, os.path.basename(image_path).replace('.jpg', '.txt'))
    with open(label_file, 'w') as f:
        f.write(f"{class_id} 0.5 0.5 1 1\n") # class_id x_center y_center width height

def splitdataset(source_dir, destination_dir, train_ratio=0.7, val_ratio=0.2, test_ratio=0.1):
    for segments in ['train', 'validation', 'test']:
        os.makedirs(os.path.join(destination_dir, segments), exist_ok=True)

    class_names = ['angry', 'happy', 'sad']
    class_to_id = {class_name: idx for idx, class_name in enumerate(class_names)}
    print(class_to_id)

    for class_folder in os.listdir(source_dir):
        class_path = os.path.join(source_dir, class_folder)

        if os.path.isdir(class_path):
            files = [file for file in os.listdir(class_path) if file.endswith('.jpg')]
            random.shuffle(files)

            train_split = int(len(files) * train_ratio)
            val_split = train_split + int(len(files) * val_ratio)

            train_files = files[:train_split]
            val_files = files[train_split:val_split]
            test_files = files[val_split:]

            class_id = class_to_id[class_folder]

            # Ensure class folders exist in destination splits
            for split in ['train', 'validation', 'test']:
                os.makedirs(os.path.join(destination_dir, split, class_folder), exist_ok=True)

            for files, segment in [(train_files, 'train'), (val_files, 'validation'), (test_files, 'test')]:
                # print(f"files: {files} segment: {segment}")
                for file in files:
                    # print(f"file: {file}")
                    source_file = os.path.join(class_path, file)
                    destination_file = os.path.join(destination_dir, segment, class_folder, file)
                    print(f"Copying {source_file} to {destination_file}")
                    shutil.copy(source_file, destination_file)
                    generate_label_file(source_file, class_id, os.path.join(destination_dir, segment, class_folder))

if __name__ == '__main__':
    splitdataset('images', 'dataset')
    # 30 photos each