#!/bin/bash

##PBS -l nodes=1:ppn=20,walltime=0:04:00,mem=96gb
#PBS -l select=1:ncpus=20:mem=96GB,walltime=0:04:00
#PBS -A cin_staff
#PBS -N Random_Forest_H2O
#PBS -q parallel
#PBS -V
#PBS -e $PBS_JOBNAME.$PBS_JOBID.error
#PBS -o $PBS_JOBNAME.$PBS_JOBID.out

## -l select=1:ncpus=20,mem=128GB

module load autoload r/3.3.1 

cd $PBS_O_WORKDIR

R --vanilla < 01-randomForestH2O.r
