#!/bin/sh

export GPU_ID=$1

echo $GPU_ID

cd ..
export DATASET_DIR="datasets/"

# Activate the relevant virtual environment:
python train_few_shot_system.py --name_of_args_json_file experiment_config/CUB_embedding_variant_standard_5_way_1_shot_48__20_LSLR_conditioned_0.json --gpu_to_use $GPU_ID