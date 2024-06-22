# OSSP1
건국대학교 컴퓨터공학부 오픈소스SW프로젝트1 텀프로젝트 레포지토리입니다

## How to run
```bash
git clone https://github.com/leehe228/OSSP1.git
```

### Model Server
**환경 설치**
```bash
conda create --name openmmlab python=3.8 -y
conda activate openmmlab
```

```bash
conda install pytorch torchvision -c pytorch
```

```bash
pip install -U openmim
mim install mmengine
mim install "mmcv>=2.1.0"
```

```bash
cd ./OSSP1/mmdetection
pip install -v -e .
```

```bash
cd image-classification-fastapi
pip install -r requirements.txt
```
**서버 실행**
```bash
PATH_TO_CONDA_PYTHON -m uvicorn main:app --reload
```
ex) `~/.conda/envs/mmdetection/bin/python -m uvicorn main:app --reload`

<br>

### iOS App
Github Repository의 dental-cavity-detector 폴더를 Xcode (최소 버전 17.0)로 엽니다.

<img width="1200px" alt="" src="https://github.com/leehe228/OSSP1/assets/37548919/3665aaf5-23d5-4b9d-9642-659c25ab8edd">

1. 앱을 실행할 Target (애뮬레이터 혹은 디바이스)을 선택합니다.
2. Play 버튼을 눌러 Build and Run 합니다.


![5조_최종발표_page-0001](https://github.com/leehe228/OSSP1/assets/37548919/f7f9d9ab-d8ac-4e84-b77d-b65b2900337c)
![5조_최종발표_page-0002](https://github.com/leehe228/OSSP1/assets/37548919/245dec88-f0db-4abe-aae0-b3bf2fedbf45)
![5조_최종발표_page-0003](https://github.com/leehe228/OSSP1/assets/37548919/5407badd-1c7d-4cc5-8841-b32c4915ebe7)
![5조_최종발표_page-0004](https://github.com/leehe228/OSSP1/assets/37548919/31821cc2-1bb2-4fc0-bcf2-494e75ec4083)
![5조_최종발표_page-0005](https://github.com/leehe228/OSSP1/assets/37548919/574031ce-f405-4bca-a5d9-bdb49ddb4ae6)
![5조_최종발표_page-0006](https://github.com/leehe228/OSSP1/assets/37548919/ebdbe85e-ec52-46d0-8eba-e5d98f0ca0cd)
![5조_최종발표_page-0007](https://github.com/leehe228/OSSP1/assets/37548919/b2846c2b-9601-4700-851e-bdfd4fd934a4)
![5조_최종발표_page-0008](https://github.com/leehe228/OSSP1/assets/37548919/cc95ce7b-bb8d-4e5c-85ef-49300ac2c3a0)
![5조_최종발표_page-0009](https://github.com/leehe228/OSSP1/assets/37548919/92f5f0cf-86f5-4baa-8527-81225e018a48)
![5조_최종발표_page-0010](https://github.com/leehe228/OSSP1/assets/37548919/d31ee298-148e-489a-b5ca-459aba253243)
![5조_최종발표_page-0011](https://github.com/leehe228/OSSP1/assets/37548919/104a243e-6319-48a6-bb82-8db889967988)
![5조_최종발표_page-0012](https://github.com/leehe228/OSSP1/assets/37548919/fef351fe-9939-46dc-9470-7bf4b86ba83f)
![5조_최종발표_page-0013](https://github.com/leehe228/OSSP1/assets/37548919/dec41907-f8ba-4b3e-9af8-4315162ca562)
![5조_최종발표_page-0014](https://github.com/leehe228/OSSP1/assets/37548919/da4f2579-37b2-4b49-9b1b-1fb28ba201eb)
![5조_최종발표_page-0015](https://github.com/leehe228/OSSP1/assets/37548919/50363285-1f7a-4079-b72c-6ef08f7affb1)
![5조_최종발표_page-0016](https://github.com/leehe228/OSSP1/assets/37548919/38ff7e99-cc49-4d86-ac47-b57297c6b40f)
![5조_최종발표_page-0017](https://github.com/leehe228/OSSP1/assets/37548919/f6c61e1f-e965-4746-9799-dcffe13fb29c)
![5조_최종발표_page-0018](https://github.com/leehe228/OSSP1/assets/37548919/fb60ba61-5c47-4219-86b8-131d3dada6d0)
![5조_최종발표_page-0019](https://github.com/leehe228/OSSP1/assets/37548919/7d965fcb-e6d1-4760-9a15-8d3a04ac1381)
![5조_최종발표_page-0020](https://github.com/leehe228/OSSP1/assets/37548919/18a8032d-88c9-42e2-9e3d-ba7b1f589097)
![5조_최종발표_page-0021](https://github.com/leehe228/OSSP1/assets/37548919/31fca967-367e-45f4-9a8b-66820bd168f7)
![5조_최종발표_page-0022](https://github.com/leehe228/OSSP1/assets/37548919/4d4a1bfa-9d41-447a-9983-4d2869499163)
![5조_최종발표_page-0023](https://github.com/leehe228/OSSP1/assets/37548919/d5fb5366-5d61-4c5c-91ff-b3126a455959)
![5조_최종발표_page-0024](https://github.com/leehe228/OSSP1/assets/37548919/48b49c93-a66e-41ef-9f93-e0c2d75aba24)
![5조_최종발표_page-0025](https://github.com/leehe228/OSSP1/assets/37548919/e6b33851-3998-468e-999f-e3b3beac3c1a)
![5조_최종발표_page-0026](https://github.com/leehe228/OSSP1/assets/37548919/65c858f7-d94a-4ba8-88c5-8c1754506790)
![5조_최종발표_page-0027](https://github.com/leehe228/OSSP1/assets/37548919/4d1d771e-8116-4018-809d-4b09b4a19a2f)
![5조_최종발표_page-0028](https://github.com/leehe228/OSSP1/assets/37548919/4106fbb6-b452-4ade-b5a7-81422605182b)
![5조_최종발표_page-0029](https://github.com/leehe228/OSSP1/assets/37548919/210e5c8e-2c00-4b2d-ab89-fe396c062562)
![5조_최종발표_page-0030](https://github.com/leehe228/OSSP1/assets/37548919/5685174b-ed53-4cee-9b85-48125456cce7)
![5조_최종발표_page-0031](https://github.com/leehe228/OSSP1/assets/37548919/e7b68c1b-c493-45e1-b8be-98530471b8b5)
![5조_최종발표_page-0032](https://github.com/leehe228/OSSP1/assets/37548919/30cc2c7b-1ad9-4fd1-889e-74d9451d9fa4)
![5조_최종발표_page-0033](https://github.com/leehe228/OSSP1/assets/37548919/ec35cbf4-7384-4fa8-b1b5-8be326de1627)
![5조_최종발표_page-0034](https://github.com/leehe228/OSSP1/assets/37548919/692e931d-e156-4436-af18-839e414f5504)
![5조_최종발표_page-0035](https://github.com/leehe228/OSSP1/assets/37548919/d72de5d9-f9f6-42ed-a4fd-bb4c6c3e061c)
![5조_최종발표_page-0036](https://github.com/leehe228/OSSP1/assets/37548919/c02f881b-e7bf-4e29-9924-29f072d060fb)
![5조_최종발표_page-0037](https://github.com/leehe228/OSSP1/assets/37548919/0555bfc5-21e1-4d7b-be1a-9cbbd99e16d9)
![5조_최종발표_page-0038](https://github.com/leehe228/OSSP1/assets/37548919/38d9bc1c-e4a3-4cda-ad25-30472b973cd4)
![5조_최종발표_page-0039](https://github.com/leehe228/OSSP1/assets/37548919/da28ea6a-a1d7-495e-a0b1-fb1478dec934)
![5조_최종발표_page-0040](https://github.com/leehe228/OSSP1/assets/37548919/8561510d-47b9-45dc-a0f6-032aceefe57e)
![5조_최종발표_page-0041](https://github.com/leehe228/OSSP1/assets/37548919/cf0a262c-dec9-4cb4-a1ad-d9667579babe)
![5조_최종발표_page-0042](https://github.com/leehe228/OSSP1/assets/37548919/039e0c19-7665-443c-8cf0-19d4a87086f9)
![5조_최종발표_page-0043](https://github.com/leehe228/OSSP1/assets/37548919/90441552-6d74-4743-802b-85b3b098a112)
![5조_최종발표_page-0044](https://github.com/leehe228/OSSP1/assets/37548919/631ab05b-8bec-4a49-813f-91bcf8254a3f)
![5조_최종발표_page-0045](https://github.com/leehe228/OSSP1/assets/37548919/e76b983d-435f-4dc6-8c52-80236526fe81)
![5조_최종발표_page-0046](https://github.com/leehe228/OSSP1/assets/37548919/06242327-f009-4e06-9f87-d4ca7e3a588d)
![5조_최종발표_page-0047](https://github.com/leehe228/OSSP1/assets/37548919/056092f7-68a2-4ab2-a682-f0e7cb245de6)
