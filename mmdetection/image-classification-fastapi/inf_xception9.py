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

from efficientnet_pytorch import EfficientNet

from torchvision import transforms
from sklearn.model_selection import train_test_split
from sklearn.metrics import f1_score, roc_auc_score, roc_curve
from sklearn.metrics import precision_score, recall_score
from sklearn.metrics import precision_recall_fscore_support, roc_auc_score

from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score, f1_score
# from tensorboardX import SummaryWriter

DATA_DIR = "/hoeunlee228/Dataset/"

TRAIN_DATASET_DIR = op(DATA_DIR, "train_odata")
TRAIN_IMAGE_DIR = op(TRAIN_DATASET_DIR, "image")
TRAIN_JSON_DIR = op(TRAIN_DATASET_DIR, "json")

TEST_DATASET_DIR = op(DATA_DIR, "test_odata")
TEST_IMAGE_DIR = op(TEST_DATASET_DIR, "image")
TEST_JSON_DIR = op(TEST_DATASET_DIR, "json")

train_file_list = list(map(lambda x : x.split(".")[0], os.listdir(TRAIN_IMAGE_DIR)))
train_image_list = os.listdir(TRAIN_IMAGE_DIR)
train_json_list = os.listdir(TRAIN_JSON_DIR)
print("number of train file:", len(train_file_list))

test_file_list = list(map(lambda x : x.split(".")[0], os.listdir(TEST_IMAGE_DIR)))
test_image_list = os.listdir(TEST_IMAGE_DIR)
test_json_list = os.listdir(TEST_JSON_DIR)
print("number of train file:", len(test_file_list))

train_df = pd.read_csv("/hoeunlee228/Dataset/train_df.csv")
# print(train_df.head())
train_df['is_decayed'].value_counts()

not_decayed_rows = train_df[train_df['is_decayed'] == False]
decayed_rows = train_df[train_df['is_decayed'] == True]
print("total not decayed rows:", len(not_decayed_rows), "total decayed rows", len(decayed_rows))

num_samples_not_decayed = 28136 * 3
num_samples_decayed = 28136

print("args num sampled not decayed:", num_samples_not_decayed, "args num sampled decayed:", num_samples_decayed)

random_samples_not_decayed = random.sample(range(len(not_decayed_rows)), num_samples_not_decayed)
not_decayed_sampled_df = not_decayed_rows.iloc[random_samples_not_decayed]
print("num of not decayed sampled list", len(not_decayed_sampled_df))

random_samples_decayed = random.sample(range(len(decayed_rows)), num_samples_decayed)
decayed_sampled_df = decayed_rows.iloc[random_samples_decayed]
print("num of decayed sampled list", len(decayed_sampled_df))

train_file_list_not_decayed_sampled = list(map(lambda x : f"{x[0]}_{x[1]}", not_decayed_sampled_df[['file', 'teeth_idx']].values.tolist()))
train_file_list_decayed_sampled = list(map(lambda x : f"{x[0]}_{x[1]}", decayed_sampled_df[['file', 'teeth_idx']].values.tolist()))
print("num of sampled file list (not decayed, decayed):", len(train_file_list_not_decayed_sampled), len(train_file_list_decayed_sampled))

sampled_train_list = train_file_list_not_decayed_sampled + train_file_list_decayed_sampled
print("total num of sampled train list:", len(sampled_train_list))

class ToothDataset(Dataset):
    def __init__(self, data_dir, file_list, transform=None, aug_transform=None):
        self.data_dir = data_dir
        self.file_list = file_list
        self.transform = transform
        self.aug_transform = aug_transform

    def __len__(self):
        return len(self.file_list)
    
    def _load_image(self, image_path):
        assert os.path.exists(op(self.data_dir, "image", image_path))
        # return cv2.cvtColor(cv2.imread(op(self.data_dir, "image", image_path)), cv2.COLOR_BGR2RGB)
        return im.open(op(self.data_dir, "image", image_path)).convert("RGB")
    
    def __getitem__(self, index):
        image_path = self.file_list[index] + ".png"
        json_path = self.file_list[index] + ".json"

        image = self._load_image(image_path)

        with open(op(self.data_dir, "json", json_path), 'r') as json_file:
            data = json.load(json_file)

        decayed = data["tooth"][0]["decayed"]
        target = 1 if decayed else 0

        if self.transform:
            image = self.transform(image)

        if self.aug_transform:
            image = self.aug_transform(image)

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
    "model": "xception",
    "gpu": 0,
    # 데이터 위치
    "root": "/hoeunlee228/Dataset/test_odata/",
    # pth
    "save_fn": "/hoeunlee228/weights/2023-12-15_01_57/xception_epoch9.pth"
})

assert os.path.isfile(args.save_fn), 'wrong path'
assert args.model in ['xception', 'resnet101', 'efficientnetb3']

if args.model == 'xception':
    model = xception(num_out_classes=2, dropout=0.5)
    print("=> creating model '{}'".format('xception'))
    model = model.cuda(args.gpu)
elif args.model == 'efficientnetb3':
    model = EfficientNet.from_name('efficientnet-b3')
    print("=> creating model '{}'".format('efficientnet-b3'))
    model = model.cuda(args.gpu)
elif args.model == 'resnet101':
    model = ResNet101(num_out_classes=2, dropout=0.5)
    print("=> creating model '{}'".format('resnet101'))
    model = model.cuda(args.gpu)

model.load_state_dict(torch.load(args.save_fn)['state_dict'])
print("=> model weight '{}' is loaded".format(args.save_fn))

model = model.eval()

test_df = pd.read_csv("/hoeunlee228/test_df.csv", index_col=0)

# collect all images
print(len(test_file_list))

# prepare pred dict
test_predict_dict = {}
image_inf_list = []

for f in os.listdir("/hoeunlee228/Dataset/test_data/image/"):
    test_predict_dict[f] = []

# predict label
m = nn.Softmax()

with torch.no_grad():
    for tf in tqdm(test_file_list):
        image_path = op(TEST_DATASET_DIR, "image", tf + ".png")
        image = im.open(image_path).convert('RGB')
        image = valid_aug_transform(image)
        image = torch.unsqueeze(image, dim=0)
        image = image.cuda(args.gpu, non_blocking=True)

        original_f = tf.split("_")[0] + "_" + tf.split("_")[1] + ".png"
        file_name = tf.split("_")[0] + "_" + tf.split("_")[1]
        teeth_idx = int(tf.split("_")[2])

        output = model(image)
        output = m(output)[0]  # apply softmax

        # 0 = not decayed
        # write to submission file
        if output[0] > output[1]:
            test_predict_dict[original_f].append(False)
            image_inf_list.append([file_name, teeth_idx, False, (output[0].cpu().item(), output[1].cpu().item())])

        # 1 = decayed
        else:
            test_predict_dict[original_f].append(True)
            image_inf_list.append([file_name, teeth_idx, True, (output[0].cpu().item(), output[1].cpu().item())])

print("predicted finished:", len(test_predict_dict.keys()))
print("len of preds:", len(image_inf_list))

inf_df = pd.DataFrame(image_inf_list, columns=['file', 'teeth_idx', 'pred', 'pred_probs'])
csv_save_path = "/hoeunlee228/inf/inf_" + args.save_fn.split("/")[-1].replace(".pth", "") + "_df.csv"
print("csv file saved at", csv_save_path)
inf_df.to_csv(csv_save_path)