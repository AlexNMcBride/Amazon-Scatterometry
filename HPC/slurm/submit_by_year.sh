# submit_by_year $ers_num $year

scripts_path=/home/alexmc99/ERS_work/scripts/ERS$1_scripts
log_path=/home/alexmc99/ERS_work/scripts/logs
cd $2
for job in $(ls $scripts_path/$2*.sh); do
	filename=$(basename $job .sh)
	touch "$log_path/"$filename"_log.txt"
	sbatch $job > "$log_path/"$filename"_log.txt"
done
