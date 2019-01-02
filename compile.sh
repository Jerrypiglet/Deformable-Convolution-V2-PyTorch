#!/usr/bin/env bash

PYTHON=${PYTHON:-"python"}

echo "Building roi align op..."
cd mmdet/ops/roi_align
if [ -d "build" ]; then
    rm -r build
fi
$PYTHON setup.py build_ext --inplace

echo "Building roi pool op..."
cd ../roi_pool
if [ -d "build" ]; then
    rm -r build
fi
$PYTHON setup.py build_ext --inplace

echo "Building nms op..."
cd ../nms
make clean
make PYTHON=${PYTHON}

cd ../dcn/src
nvcc -c -o deform_conv_cuda_kernel.cu.o deform_conv_cuda_kernel.cu -x cu -Xcompiler -fPIC -std=c++11

cd cuda

# compile modulated deform conv
nvcc -c -o modulated_deform_im2col_cuda.cu.o modulated_deform_im2col_cuda.cu -x cu -Xcompiler -fPIC

# compile deform-psroi-pooling
nvcc -c -o deform_psroi_pooling_cuda.cu.o deform_psroi_pooling_cuda.cu -x cu -Xcompiler -fPIC

cd ../..
CC=g++ python build.py
python build_modulated.py
