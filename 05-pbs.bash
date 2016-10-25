#!/bin/bash

#PBS -l nodes=1:ppn=10,walltime=0:04:00,mem=64gb
#PBS -N randomForest-Test
#PBS -A cin_staff
#PBS -q parallel
#PBS -V
#PBS -e randomForest-Test.error
#PBS -o randomForest-Test.out

module load autoload r/3.3.1 

cd $CINECA_SCRATCH/r-bench

R --vanilla < 01-randomForestR.r