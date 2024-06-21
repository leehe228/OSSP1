import os
import os.path as osp

from mmengine.config import Config, DictAction
from mmengine.registry import RUNNERS
from mmengine.runner import Runner

from mmdet.utils import setup_cache_size_limit_of_dynamo

from pprint import pprint

def parse_args():
    args = dict()
    
    args['config'] = "/home/dmsai2/mmdetection/my_configs/faster-rcnn_r50_fpn_1x_coco.py" # train config file path
    args['work_dir'] = "/home/dmsai2/mmdetection/work_dir/" # the dir to save logs and models
    args['amp'] = False # enable automatic-mixed-precision training
    args['auto_scale_lr'] = True # enable automatically scaling LR
    args['resume'] = None # If specify checkpoint path, resume from it, while if not specify, try to auto resume from the latest checkpoint in the work directory.
    args['cfg_options'] = None # override some settings in the used config
    args['launcher'] = ['none', 'pytorch', 'slurm', 'mpi'][0] # job launcher
    args['local_rank'] = 0 # local rank of the process
    
    if 'LOCAL_RANK' in os.environ:
        args['local_rank'] = str(args['local_rank'])
        
    return args

args = parse_args()
pprint(args, indent=2)

# Reduce the number of repeated compilations and improve
# training speed.
# setup_cache_size_limit_of_dynamo()

# load config
cfg = Config.fromfile(args['config'])
cfg.launcher = args['launcher']
if args['cfg_options'] is not None:
    cfg.merge_from_dict(args['cfg_options'])
    
# print config info prettier
pprint(cfg.to_dict(), indent=2)

# work_dir is determined in this priority: CLI > segment in file > filename
if args['work_dir'] is not None:
    # update configs according to CLI args if args.work_dir is not None
    cfg.work_dir = args['work_dir']
elif cfg.get('work_dir', None) is None:
    # use config filename as default work_dir if cfg.work_dir is None
    cfg.work_dir = osp.join('./work_dirs',
                            osp.splitext(osp.basename(args['config']))[0])
    
print("work_dir:", cfg.work_dir)

# cfg.data_root = "C:\\Users\\uamdt3\\Desktop\\mmdetection\\data\\coco\\" # the root of the dataset
print("data_root:", cfg.data_root)

# enable automatic-mixed-precision training
if args['amp'] is True:
    cfg.optim_wrapper.type = 'AmpOptimWrapper'
    cfg.optim_wrapper.loss_scale = 'dynamic'


# enable automatically scaling LR
if args['auto_scale_lr']:
    if 'auto_scale_lr' in cfg and \
            'enable' in cfg.auto_scale_lr and \
            'base_batch_size' in cfg.auto_scale_lr:
        cfg.auto_scale_lr.enable = True
    else:
        raise RuntimeError('Can not find "auto_scale_lr" or '
                            '"auto_scale_lr.enable" or '
                            '"auto_scale_lr.base_batch_size" in your'
                            ' configuration file.')
        
print("auto_scale_lr:", cfg.auto_scale_lr)


# resume is determined in this priority: resume from > auto_resume
if args['resume'] == 'auto':
    cfg.resume = True
    cfg.load_from = None
elif args['resume'] is not None:
    cfg.resume = True
    cfg.load_from = args['resume']

# build the runner from config
if 'runner_type' not in cfg:
    # build the default runner
    runner = Runner.from_cfg(cfg)
else:
    # build customized runner from the registry
    # if 'runner_type' is set in the cfg
    runner = RUNNERS.build(cfg)
    
pprint(runner, indent=2)

runner.train()