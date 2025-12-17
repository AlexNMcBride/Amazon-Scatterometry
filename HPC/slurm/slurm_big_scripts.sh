scripts_path=/home/alexmc99/ERS_work/scripts/big_scripts
log_path=/home/alexmc99/ERS_work/scripts/logs
cd $2
for job in $(ls $scripts_path/*.sh); do
	filename=$(basename $job .sh)
	touch "$log_path/"$filename"_log.txt"
	$($scripts_path/$filename.sh) > "$log_path/"$filename"_log.txt"
done
