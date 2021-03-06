# Currently, the script will create the files in the directory it is run in.

# Arguments:
# 1 = Cluster results, .csv or .tsv format.
# 2 = Sequences, .fasta format.
# 3 = Output file.
# 4 = Options, as a string.


CLU_F=$1
SEQ_F=$2
OUT_F=$3

ROOT_DIR=$(pwd)

printf "\n\n"
echo Cluster results file:		$CLU_F
echo Sequences file:			$SEQ_F
echo Merged cluster output file:	$OUT_F
echo Options:				$SEARCH_OPTIONS
printf "\n\n"

mkdir mmseqs-output
mkdir mmseqs-output/tmp

# Extracting the sequence information of the representative sequences from the .csv data.
grep -f <(awk '{print $1}' $CLU_F | sort | uniq) -A1 --no-group-separator $SEQ_F > rep-seqs.fasta


# Making the databases.
mmseqs createdb rep-seqs.fasta $ROOT_DIR/mmseqs-output/repsDB


# Performing search.
mmseqs search $ROOT_DIR/mmseqs-output/repsDB $ROOT_DIR/mmseqs-output/repsDB $ROOT_DIR/mmseqs-output/searchDB $ROOT_DIR/mmseqs-output/tmp $SEARCH_OPTIONS


# Converting the output and sorting it .
mmseqs convertalis $ROOT_DIR/mmseqs-output/repsDB $ROOT_DIR/mmseqs-output/repsDB $ROOT_DIR/mmseqs-output/searchDB search.tsv
sort -k11 -g -o search.tsv search.tsv


# Finding RBs.
python ../../find_RHs.py $ROOT_DIR "search.tsv" "searchRHs.tsv" $SEARCH_EVAL_THRESHOLD


# Relabeling cluster results accordingly.
python ../../relabel_seqs.py $ROOT_DIR $CLU_F "searchRHs.tsv" $OUT_F

