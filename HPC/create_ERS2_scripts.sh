#!/bin/bash

start_year=1996
end_year=2011
start_date=086
end_date=185
ers_num=2
index=1

script_path=/home/alexmc99/ERS_work/scripts/ERS"$ers_num"_scripts
log_file="/home/alexmc99/ERS_work/scripts/logs/ERS2_generate_log.txt"

echo "" > $log_file
for year in $(seq $start_year $end_year); do
    if [ $year == $start_year ]; then
        first_date=$start_date
    else
        first_date=1
    fi
    if [ $year == $end_year ]; then
        last_date=$end_date
    else
        last_date=365
    fi
    for date in $(seq $first_date 6 $last_date); do
    	slurm_setup="
		#! /bin/bash\n#SBATCH --time=12:00:00\n#SBATCH --ntasks=1\n#SBATCH --mem-per-cpu=24576M\n#SBATCH --mail-user=alexmc99@byu.edu\n#SBATCH --mail-type=END\n#SBATCH --mail-type=FAIL\n\n#SBATCH -J "$year-$date-ERS$ers_num"\nexport OMP_NUM_THREADS=1\n\nmodule load matlab\n"

  	filename="$year"_"$date"_ERS"$ers_num".sh
    	echo -e $slurm_setup > $script_path/$filename
        cmd="matlab -nodisplay -nojvm -nosplash -r \"addpath(genpath(\\\"/home/alexmc99/ERS_work/scripts\\\")); generate_local_ERS_sir($ers_num, $year, $date, $date); exit\""
        
        echo $cmd >> $script_path/$filename
        echo "exit" >> $script_path/$filename
        echo $cmd >> $log_file
        index=$(($index + 1))
    done
done
chmod 777 $script_path/*
