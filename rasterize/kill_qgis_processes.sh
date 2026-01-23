instrument=$1
kill -9 $(ps aux | grep $instrument | awk '{print $2}')
