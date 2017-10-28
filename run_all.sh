#/bin/bash
echo "" > runstatus.txt

datasetf=$1
echo "Dataset folder: $datasetf"
echo "Dataset folder: $datasetf" >> runstatus.txt

spmv=$2
echo "SparseMatrixDenseVector excutable: $spmv"
echo "SparseMatrixDenseVector excutable: $spmv" >> runstatus.txt

platform=$3
echo "Platform: $platform"
echo "Platform: $platform" >> runstatus.txt

device=$4
echo "Device: $device"
echo "Device: $device" >> runstatus.txt

host=$(hostname)

# Get some unique data for the experiment ID
now=$(date +"%Y-%m-%dT%H-%M-%S%z")
hsh=$(git rev-parse HEAD)
exID="$hsh-$now"

start=$(date +%s)

mkdir -p "results/results-$exID"

matrixcount=$(ls $datasetf | wc -l)
taskcount=$((matrixcount)) 
echo "taskcount: $taskcount"
echo "taskcount: $taskcount" >> runstatus.txt

i=0
for m in $(cat $datasetf/datasets.txt);
do
	rdir="results/results-$exID/$m"
	mkdir -p $rdir

	echo "Processing matrix: $m - $i/$taskcount" 
	echo "Processing matrix: $m - $i/$taskcount"  >> runstatus.txt

	runstart=$(date +%s)

	$spmv -p $platform \
	  -d $device \
	  -i 10 \
	  -m $datasetf/$m/$m.mtx \
	  -f $m \
	  -n $host \
	  -a \
	  -e $exID &>$rdir/result_adaptive.txt

	rc=$?
	if [[ $rc != 0 ]]; then
		echo "adaptive run failed!" 
		echo "adaptive run failed!" >> runstatus.txt 
	fi

	$spmv -p $platform \
	  -d $device \
	  -i 10 \
	  -m $datasetf/$m/$m.mtx \
	  -f $m \
	  -n $host \
	  -e $exID &>$rdir/result_vectorized.txt

	rc=$?
	if [[ $rc != 0 ]]; then
		echo "vectorized run failed!" 
		echo "vectorized run failed!" >> runstatus.txt 
	fi

	runend=$(date +%s)
	runtime=$((runend-runstart))
	scripttime=$((runend-start))

	echo "Run took $runtime seconds, total time of $scripttime seconds"
	echo "Run took $runtime seconds, total time of $scripttime seconds" >> runstatus.txt

	estimated_total=$(bc <<< "scale=4;(($scripttime/$i)*$taskcount)/(60*60*24)")
	current_days=$(bc <<< "scale=4;$scripttime/(60*60*24)")
	estimated_percentage=$(bc <<< "scale=4;($current_days*100)/($estimated_total)")

	echo "Estimated total days: $estimated_total - spent $current_days - i.e $estimated_percentage%" 
	echo "Estimated total days: $estimated_total - spent $current_days - i.e $estimated_percentage%" >> runstatus.txt

	i=$(($i + 1))
done

echo "finished experiments"
echo "finished experiments" >> runstatus.txt
