[![PWC](https://img.shields.io/endpoint.svg?url=https://paperswithcode.com/badge/learning-to-learn-by-self-critique/few-shot-image-classification-on-cub-200-5-1)](https://paperswithcode.com/sota/few-shot-image-classification-on-cub-200-5-1?p=learning-to-learn-by-self-critique)
[![PWC](https://img.shields.io/endpoint.svg?url=https://paperswithcode.com/badge/learning-to-learn-by-self-critique/few-shot-image-classification-on-cub-200-5)](https://paperswithcode.com/sota/few-shot-image-classification-on-cub-200-5?p=learning-to-learn-by-self-critique)
[![PWC](https://img.shields.io/endpoint.svg?url=https://paperswithcode.com/badge/learning-to-learn-by-self-critique/few-shot-image-classification-on-mini-1)](https://paperswithcode.com/sota/few-shot-image-classification-on-mini-1?p=learning-to-learn-by-self-critique)	

# Learning to Learn via Self-Critique in Pytorch
The original code for the paper ["Learning to Learn via Self-Critique"](https://arxiv.org/abs/1905.10295).

## Introduction

Welcome to the code repository of Learning to Learn via Self-Critique. This repository includes code for training both MAML++ and SCA models as well as data providers and the datasets for both. By using this codebase you agree to the terms 
and conditions in the LICENSE file.

## Installation

The code uses Pytorch to run, along with many other smaller packages. To take care of everything at once, we recommend 
using the conda package management library. More specifically, 
[miniconda3](https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh), as it is lightweight and fast to install.
If you have an existing miniconda3 installation please start at step 3. 
If you want to  install both conda and the required packages, please run:
 1. ```wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh```
 2. Go through the installation.
 3. Activate conda
 4. conda create -n meta_learning_pytorch_env python=3.6.
 5. conda activate meta_learning_pytorch_env
 6. At this stage you need to choose which version of pytorch you need by visiting [here](https://pytorch.org/get-started/locally/)
 7. Choose and install the pytorch variant of your choice using the conda commands.
 8. Then run ```bash install.sh```

To execute an installation script simply run:
```bash <installation_file_name>```

To activate your conda installations simply run:
```conda activate```

## Datasets
We provide functionality for both Mini-ImageNet and CUB. We have automated the unzipping and usage of the datasets, all one needs to do is download them from:

- [mini_imagenet gdrive folder](https://drive.google.com/file/d/1qQCoGoEJKUCQkk8roncWH7rhPN7aMfBr/view?usp=sharing)
- [cub gdrive folder](https://drive.google.com/file/d/1y6bSXpxDQ1cwuX4Qw9X4gImLWvzn4NpN/view?usp=sharing)

Once downloaded, please place them in the datasets folder in this repo. The rest will be done automagically when you 
run an experiment.

Note: By downloading and using the mini-imagenet datasets, you accept terms and conditions found in [imagenet_license.md](https://github.com/AntreasAntoniou/HowToTrainYourMAMLPytorch/blob/master/imagenet_license.md) 

#### Other Datasets:
We provide a mechanism for quick and easy training of models on any image-based datasets. 
Read the data.py description in the [Code Overview](#code-overview) Section for details on how to train models on your own datasets.  

## Code Overview:

- datasets folder: Contains the dataset pbzip files and folders containing the images in a structure readable by the 
custom data provider.
- experiments_config: Contains configuration files for each and every experiment listed in the experiments script folder.
All of the scripts are automatically generated using the script_generation_tools/generate_configs.py script.
- experiment_scripts: Contains scripts that can reproduce every results in the paper. Each script is easily runnable
simply by executing:
```bash <experiment-script.sh>```
- experiment_template_config: Contains the template configuration files. These files have variables declared in their 
files indicated as $variable_name$, which are then filled automatically by the generate_configs.py script. This way one
can vary various hyperparameters automatically.
- script_generation_tools: Contains scripts and template files for the automatic generation of experiment scripts.
- utils: Contains utilities for dataset extraction, parser argument extraction and storage of statistics and others.
- data.py: Contains the data providers for the few shot meta learning task generation. The data provider is agnostic
to dataset, which means it can be used with any dataset. Most importantly, it can only scan and use datasets when they 
are presented in a specific format. The two formats that the data provider can read are:
1. A folder structure where the top level folders are the classes and the contained images of each folders, the images 
of that class, as illustrated below:
```
Dataset
    ||______
    |       |
 class_0 class_1 ... class_N
    |       |___________________
    |                           |
samples for class_0    samples for class_1
```
In this case the data provider will split the data into 3 sets, train, val and test using the train_val_test_split 
variable found in the experiment_config files. However, in the case where you have a pre-split dataset, such 
as mini_imagenet, you can instead use:
2. A folder structure where the higher level folders indicate the set (i.e. train, val, test), the mid level folders 
(i.e. the folders within a particular set) indicate the class and the images within each class indicate the images of 
that class.
```
Dataset
    ||
 ___||_________
|       |     |
Train   Val  Test
|_________________________
    |       |            |
 class_0 class_1 ... class_N
    |       |___________________
    |                           |
samples for class_0    samples for class_1
```
- experiment_builder.py: Builds an experiment ready to train and evaluate your meta learning models. It supports automatic
checkpoining and even fault-tolerant code. If your script is killed for whatever reason, you can simply rerun the script.
It will find where it was before it was killed and continue onwards towards convergence!

- few_shot_learning_system.py: Contains the meta_learning_system class which is where most of MAML++ and SCA are actually
implemented. It takes care of inner and outer loop optimization, checkpointing, reloading and statistics generation, as 
well as setting the rng seeds in pytorch.

- meta_neural_network_architectures: Contains new pytorch layers which are capable of utilizing either internal 
parameter or externally passed parameters. This is very useful in a meta-learning setting where inner-loop update 
steps are applied on the internal parameters. By allowing layers to receive weight which they will only use for the 
current inference phase, one can easily build various meta-learning models, which require inner_loop optimization 
without havin to reload the internal parameters at every step. Essentially at the technical level, the meta-layers 
forward prop looks like:
```python
def forward(x, weights=None):

    if weights is not None:
        out = layer(x, weights)
    else:
        out = layer(x, self.parameters)
    return out

```
If we pass weights to it, then the layer/model will use those to do inference, otherwise it will use its internal 
parameters. Doing so allows a model like MAML to be build very easily. At the first step, use weights=None and for any
subsequent step just pass the new inner loop/dynamic weights to the network.
- meta_optimizer.py: Contains inner loop optimizers for MAML++ and SCA.
- standard_neural_network_architectures.py: Contains pytorch modules implementing various layers and network types. Contrary to meta_neural_network_architectures.py, the modules in this
file do not include inner-loop optimization features. Thus, modules in this file can only learn static parameters for a network that do not change during inference.
- train_few_shot_system.py: A very minimal script that combines the data provider with a meta learning system and sends them
 to the experiment builder to run an experiment. Also takes care of automated extraction of data if they are not 
 available in a folder structure.

# Running an experiment

To run an experiment from the paper on Omniglot:
1. Activate your conda environment ```conda activate pytorch_meta_learning_env```
2. cd experiment_scripts
3. Find which experiment you want to run.
4. ```bash experiment_script.sh <gpu_id or -1 for cpu>```

Note: By downloading and using the mini-imagenet datasets, you accept terms and conditions found in [imagenet_license.md](https://github.com/AntreasAntoniou/HowToTrainYourMAMLPytorch/blob/master/imagenet_license.md) 

To run an experiment from the paper on Mini-Imagenet:
1. Activate your conda environment ```conda activate pytorch_meta_learning_env```
2. Download the mini_imagenet dataset from the [gdrive folder](https://drive.google.com/file/d/1ljP5AaiwZoS6LmEx6UquG_UScUaUd4-m/view?usp=sharing)
3. copy the .pbzip file in datasets
4. cd experiment_scripts
5. Find which experiment you want to run.
6. ```bash experiment_script.sh <gpu_id or -1 for cpu>```

To run a custom/new experiment on any dataset:
1. Activate your conda environment ```conda activate pytorch_meta_learning_env```
2. Make sure your data is in datasets/ in a folder structure the data provider can read.
3. cd experiment_template_config
4. Find an experiment close to what you want to do and open its config file.
5. For example let's take an omniglot experiment on maml++. Make changes to the hyperparameters such that your 
experiment takes form. Note that the variables in $<variable>$ are hyperparameters automatically filled by the config
generation script. If you add any new of those, you'll have to change the generate_configs.py file in order to tell it
what to fill those with.
6.
    ```json
    {
      "batch_size":16,
      "image_height":28,
      "image_width":28,
      "image_channels":1,
      "gpu_to_use":0,
      "num_dataprovider_workers":8,
      "max_models_to_save":5,
      "dataset_name":"omniglot_dataset",
      "dataset_path":"omniglot_dataset",
      "reset_stored_paths":false,
      "experiment_name":"MAML++_Omniglot_$num_classes$_way_$samples_per_class$_shot_$train_update_steps$_filter_multi_step_loss_with_max_pooling_seed_$train_seed$",
      "train_seed": $train_seed$, "val_seed": $val_seed$,
      "train_val_test_split": [0.70918052988, 0.03080714725, 0.2606284658],
      "indexes_of_folders_indicating_class": [-3, -2],
      "sets_are_pre_split": false,
    
      "total_epochs": 150,
      "total_iter_per_epoch":500, "continue_from_epoch": -2,
    
      "max_pooling": true,
      "per_step_bn_statistics": true,
      "learnable_batch_norm_momentum": false,
    
      "dropout_rate_value":0.0,
      "min_learning_rate":0.001,
      "meta_learning_rate":0.001,   "total_epochs_before_pause": 150,
      "task_learning_rate":-1,
      "init_task_learning_rate":0.4,
      "first_order_to_second_order_epoch":80,
    
      "norm_layer":"batch_norm",
      "cnn_num_filters":64,
      "num_stages":4,
      "number_of_training_steps_per_iter":$train_update_steps$,
      "number_of_evaluation_steps_per_iter":$val_update_steps$,
      "cnn_blocks_per_stage":1,
      "num_classes_per_set":$num_classes$,
      "num_samples_per_class":$samples_per_class$,
      "num_target_samples": $target_samples_per_class$,
    
      "second_order": true,
      "optimize_final_target_loss_only":false,
      "use_gdrive":false
    }
    
    ```
7. ```cd script_generation_tools```
8. ```python generate_configs.py; python generate_scripts.py```
9. Your new scripts can be found in the experiment_scripts, ready to be run.

# Acnknowledgments
Thanks to the University of Edinburgh and ESPRC research council for funding this research.
 
 
# Learning_to_learn_via_Self-Critique
