# import numpy as np
from PIL import Image
from io import BytesIO
from pathlib import Path
from typing import Union

from tqdm import tqdm

from datetime import datetime

import numpy as np
import torch
# import mmcv
# from mmengine.config import Config

import os
import sys
from os import path

from inf import inference

print(__file__)

# print(os.path.abspath(os.path.dirname("/home/dmsai2/image-classification-fastapi/mmdetection/mmdet/apis/__init__.py")))
# print("="*10, "\n\n")
# sys.path.append(os.path.abspath(os.path.dirname("/home/dmsai2/image-classification-fastapi/mmdetection/mmdet/apis/__init__.py")))
# sys.path.append(os.path.abspath(os.path.dirname("/home/dmsai2/image-classification-fastapi/mmdetection/mmdet/apis")))
# sys.path.append(os.path.abspath(os.path.dirname("/home/dmsai2/image-classification-fastapi/mmdetection/mmdet")))
# from inference import init_detector, inference_detector

from pathlib import Path
from typing import Union

import numpy as np
import torch
import mmcv
from mmengine.config import Config

# dir E의 경로를 sys.path에 추가
dir_e_path = os.path.abspath(os.path.join(__file__, '../'))
if dir_e_path not in sys.path:
    sys.path.append(dir_e_path)
    
from mmdet.apis.inference import init_detector, inference_detector

def read_image(file) -> Image.Image:
    pil_image = Image.open(BytesIO(file))
    #print('print dentro da funcao --- ok ')
    return pil_image

def infer_image(
    config_path: Union[str, Path],
    checkpoint_path: [str],
    image_path: Union[str, np.ndarray],
    device: str = 'cuda:0',
    cfg_options: [dict] = None
) -> Union[dict, list]:
    """
    Perform inference on an image using a detector from MMDetection.

    Args:
        config_path (str or Path): Path to the model config file.
        checkpoint_path (str, optional): Path to the model checkpoint file.
        image_path (str or np.ndarray): Path to the image file or the image as a numpy array.
        device (str): Device to run inference on. Defaults to 'cuda:0'.
        cfg_options (dict, optional): Options to override some settings in the config. Defaults to None.

    Returns:
        dict or list: Inference results. If the input is a list of images, the output will be a list of results.
    """
    # Initialize the detector
    model = init_detector(
        config=config_path,
        checkpoint=checkpoint_path,
        device=device,
        cfg_options=cfg_options
    )

    # Perform inference
    # result = inference_detector(model, image_path)
    
    try:
        # Perform inference
        result = inference_detector(model, image_path)
    finally:
        # Clean up the GPU memory
        del model
        torch.cuda.empty_cache()

    return result

config_file = "/home/dmsai2/mmdetection/my_configs/faster-renn_r101_fpn_1x_coco.py"
checkpoint_file = "/home/dmsai2/mmdetection/work_dir/epoch_48.pth"

def transformacao(file: Image.Image):

    """#img_path = 'image3.jpeg'
    #img = image.load_img(file, target_size=(224, 224))
    img = np.asarray(file.resize((224, 224)))[..., :3]
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis=0)
    x = preprocess_input(x)
    preds = model.predict(x)
# decode the results into a list of tuples (class, description, probability)
# (one such list for each sample in the batch)
    #result = {}
    print('Predicted:', decode_predictions(preds, top=3)[0])
    #result = decode_predictions(preds, top=3)[0]
    result = decode_predictions(model.predict(x), 3)[0]
    
    response = []
    for i, res in enumerate(result):
        resp = {}
        resp["class"] = res[1]
        resp["confidence"] = f"{res[2]*100:0.2f} %"

        response.append(resp)
"""
    print(type(file))
    
    # width, height of an image "file"
    width, height = file.size
    print(width, height)
    
    # save file in temp folder file name is current yyyy-mm-dd-hh-mm-ss
    current = datetime.now().strftime("%Y%m%d%H%M%S")
    file_name = f"/home/dmsai2/mmdetection/image-classification-fastapi/temp/{current}.png"
    file.save(file_name)
        
    result = infer_image(config_file, checkpoint_file, file_name)
    
    print(result)
    
    bboxes = result.pred_instances.bboxes.cpu().numpy()
    scores = result.pred_instances.scores.cpu().numpy()
    
    response = []
    
    for i in tqdm(range(len(bboxes))):
        bbox = bboxes[i]
        score = scores[i]
        
        if score < 0.5:
            continue
        
        x1, y1, x2, y2 = bbox.astype(int)
        
        cropped = file.crop((x1, y1, x2, y2))
    
        probs = inference(cropped)

        if probs[0] > probs[1]:
            cat = 0
        else:
            cat = 1
        
        x1, x2 = float(x1), float(x2)
        y1, y2 = float(y1), float(y2)
        
        response.append({"cls": f"{cat}", "prob": float(probs[1]), "bbox": [[x1, y1], [x2, y2]]})

    print("response:")
    print(response)
    
    return response