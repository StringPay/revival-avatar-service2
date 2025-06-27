#!/bin/bash
JOBS_DIR=$(dirname $(dirname "$0"))
export PYTHONPATH=./

export MODEL_BASE=./weights
OUTPUT_BASEPATH=./results
checkpoint_path=${MODEL_BASE}/ckpts/hunyuan-video-t2v-720p/transformers/mp_rank_00_model_states.pt

# --image-size 900 is the max that an A100 can handle

export CPU_OFFLOAD=1
CUDA_VISIBLE_DEVICES=0 python3 hymm_sp/sample_gpu_poor.py \
    --input 'assets/batch.csv' \
    --ckpt ${checkpoint_path} \
    --seed 42 \
    --image-size 704 \
    --cfg-scale 7.5 \
    --infer-steps 200 \
    --use-deepcache 1 \
    --flow-shift-eval-video 5.0 \
    --save-path ${OUTPUT_BASEPATH} 
