from my_models import ResNet101, xception

import os
import easydict
from PIL import Image as im
from PIL import ImageOps
import cv2
from tqdm import tqdm
import json
import sys
import shutil
from datetime import datetime
import pandas as pd
import random

op = os.path.join

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.backends.cudnn as cudnn
from torch.utils.data import Dataset, DataLoader
from torch.optim import lr_scheduler
import torchvision.models as models

from pycocotools.coco import COCO

# from efficientnet_pytorch import EfficientNet

from torchvision import transforms
from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, roc_auc_score, roc_curve
from sklearn.metrics import precision_score, recall_score
from sklearn.metrics import precision_recall_fscore_support, roc_auc_score

from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score, f1_score
from tensorboardX import SummaryWriter

DATA_DIR = "/home/dmsai2/mmdetection/data/"

TRAIN_DATASET_DIR = op(DATA_DIR, "classification")
TRAIN_IMAGE_DIR = op(TRAIN_DATASET_DIR, "train")
TRAIN_JSON_DIR = op(TRAIN_DATASET_DIR, "annotations")

TEST_DATASET_DIR = op(DATA_DIR, "classification")
TEST_IMAGE_DIR = op(TEST_DATASET_DIR, "test")
TEST_JSON_DIR = op(TEST_DATASET_DIR, "annotations")

current_datetime = datetime.now()
formatted_datetime = current_datetime.strftime('%Y-%m-%d_%H_%M')
print(formatted_datetime)

class ToothCOCODataset(Dataset):
    def __init__(self, data_dir, ann_file, transform=None, aug_transform=None, valid=False):
        self.data_dir = data_dir
        self.coco = COCO(ann_file)
        self.image_ids = self.coco.getImgIds()
        self.transform = transform
        self.aug_transform = aug_transform
        self.valid = valid

    def __len__(self):
        return len(self.image_ids)
    
    def _load_image(self, image_id):
        image_info = self.coco.loadImgs(image_id)[0]
        image_path = op(self.data_dir, image_info['file_name'])
        assert os.path.exists(image_path), f"Image path {image_path} does not exist."
        
        if self.valid:
            return (im.open(image_path).convert("RGB"), image_info['file_name'])
        else:
            return im.open(image_path).convert("RGB")
    
    def _load_target(self, image_id):
        ann_ids = self.coco.getAnnIds(imgIds=image_id)
        anns = self.coco.loadAnns(ann_ids)
        # Assuming 'decayed' is the attribute that indicates decay
        # decayed = any(ann.get('category_id', False) for ann in anns)
        decayed = any(ann.get('category_id', False) for ann in anns)
        target = 1 if decayed else 0
        return target

    def __getitem__(self, index):
        image_id = self.image_ids[index]

        if self.valid:
            image, label = self._load_image(image_id)
        else:
            image = self._load_image(image_id)

        target = self._load_target(image_id)

        if self.transform:
            image = self.transform(image)

        if self.aug_transform:
            image = self.aug_transform(image)

        if self.valid:
            return (image, label), target
        else:
            return image, target

# 1. Zero padding to make the image square
def make_square(img):
    width, height = img.size
    max_side = max(width, height)
    left = (max_side - width) // 2
    top = (max_side - height) // 2
    right = (max_side - width) - left
    bottom = (max_side - height) - top
    padding = (left, top, right, bottom)
    return ImageOps.expand(img, padding)

mean = (0.57933619, 0.42688786, 0.33401168)
std = (0.35580848, 0.27125023, 0.22251333)

test_aug_transform = transforms.Compose([
    # 1. 이미지를 정사각형으로 만들기
    transforms.Lambda(lambda img: ImageOps.exif_transpose(img)),  # Exif 정보 처리
    transforms.Lambda(make_square),

    # 2. Resize
    transforms.Resize(size=(300, 300)),
    
    transforms.ToTensor(),
    transforms.Normalize(mean, std)
])

valid_aug_transform = transforms.Compose([
    # 1. 이미지를 정사각형으로 만들기
    transforms.Lambda(lambda img: ImageOps.exif_transpose(img)),  # Exif 정보 처리
    transforms.Lambda(make_square),

    # 2. Resize
    transforms.Resize(size=(300, 300)),

    transforms.ToTensor(),
    transforms.Normalize(mean, std)
])

args = easydict.EasyDict({    
    "gpu": 0,
    # 데이터 위치
    "root": "/home/dmsai2/mmdetection/data/classification/",
    # pth
    "save_fn": "/home/dmsai2/mmdetection/image-classification-fastapi/xception_epoch26.pth"
})

model = xception(num_out_classes=2, dropout=0.5)
print("=> creating model '{}'".format('xception'))
model = model.cuda(args.gpu)

model.load_state_dict(torch.load(args.save_fn)['state_dict'])
print("=> model weight '{}' is loaded".format(args.save_fn))

def inference(image: im.Image):
    # assert os.path.isfile(args.save_fn), 'wrong path'
    model.eval()

    # predict label
    m = nn.Softmax()

    with torch.no_grad():
        # image_path = "/home/dmsai2/mmdetection/image-classification-fastapi/front_100_11.png"
        # image = im.open(image_path).convert("RGB")
        
        image = image.convert("RGB")
        image = valid_aug_transform(image)
        image = torch.unsqueeze(image, 0)
        image = image.cuda(args.gpu, non_blocking=True)
        
        output = model(image)
        output = m(output)[0]
        
        print(f"tooth: {output[0]}, cavity: {output[1]}")
        
        return (output[0].item(), output[1].item())