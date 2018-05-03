#!/bin/sh
#BSUB -q 48G
#BSUB -o /work5/NRPB_user/u00hsj01/NTUH/PD/GATK/FAPD22_01/20180314_FAPD22_01_out
#BSUB -e /work5/NRPB_user/u00hsj01/NTUH/PD/GATK/FAPD22_01/20180314_FAPD22_01_err
#BSUB -u jacobhsu@ntuh.gov.tw
#BSUB -J 20180314_FAPD22_01
#BSUB -R 'span[hosts=1]'

java=/pkg/java/jre1.8.0_66/bin/java
wkdir="/work5/NRPB_user/u00hsj01/NTUH/PD/GATK"
sampleName=FAPD22_01
ReadTail=DHE11914-A13_H7KNFCCXY_L8_
read1="/work5/NRPB_user/u00yhl02/AI_SHARE/rawdata/Parkinsonism/"$sampleName"_"$ReadTail"1.fq.gz"
read2="/work5/NRPB_user/u00yhl02/AI_SHARE/rawdata/Parkinsonism/"$sampleName"_"$ReadTail"2.fq.gz"
#read1="/work5/NRPB_user/u00hsj01/NTUH/PD/RawData/"$sampleName"_GGCTAC_L001_R1.fastq.gz"
#read2="/work5/NRPB_user/u00hsj01/NTUH/PD/RawData/"$sampleName"_GGCTAC_L001_R2.fastq.gz"
#ref
reference="/work5/NRPB_user/u00yhl02/AI_SHARE/reference/GATK_bundle/2.8/hg19/ucsc.hg19.NC_012920.fasta"
dbsnp="/work5/NRPB_user/u00yhl02/AI_SHARE/reference/GATK_bundle/2.8/hg19/dbsnp_137.hg19.rmMT.vcf"
refPre="/work5/NRPB_user/u00yhl02/AI_SHARE/reference/GATK_bundle/2.8/hg19/ucsc.hg19.NC_012920.fasta"
#bed="/home/yamin96236/data/Overlap.bed"
bed="/work5/NRPB_user/u00yhl02/AI_SHARE/reference/Exome_Capture/Agilent/Sureselect_HumanV6/S07604514_Covered.bed"
#software
bwa="/pkg/biology/BWA/bwa_0.7.17/bwa"
gatk="/pkg/biology/GATK/gatk_3.8/GenomeAnalysisTK.jar"
samtools="/pkg/biology/SAMtools/samtools_1.6/bin/samtools"
picard="/pkg/biology/Picard_Tools/picardtools_2.14.1/picard.jar"
thread=16
platform="illumina"
library="Aglient"
id="1"
PicardBed="/work5/NRPB_user/u00yhl02/AI_SHARE/reference/Exome_Capture/Agilent/Sureselect_HumanV6/For_Picard/Sureselect_HumanV6_list.interval_list"
processDay=`date +%Y%m%d`
help='Exome Sequencing Pipeline
A simple automated script to prepare the require file for variant calling in exome sequencing
Version 0.1	By CHOI Shing Wan 
Version 0.2 Modified by Yan Li
Version 0.3 Modified by Jacob Hsu
Version 0.4 Modified by Yamin Zhang
Version 0.5 Modified by Jacob Hsu (20180308)
=======================================

Usage:   Exom_pipeline [options] -1 <Read1> -2 <Read2> -n <Sample Name>
Sample Information:
    -n    Name of the Sample                               < REQUIRED >
    -1    Path to the forward read                         < REQUIRED >
    -2    Path to the reverse read                         < REQUIRED >
    -w    working directory                                < REQUIRED >
    -k    Sequencing platform                              < default: $platform >
    -l    Sequencing Library (Capture kit used)            < default: $library >
    -i    Sample ID (unique for each sample)               < default: $id >
Programme Paths:
    -b    Path to bwa (Require ver0.7.5a or above)         < default: $bwa >
    -g    Path to gatk                                     < default: $gatk >
    -p    Path to picards MarkDuplicates.jar file          < default: $picards >
    -s    Path to samtools (Require ver1.9 or above)       < default: $sam >
    -c	  Path to collectmetrics                           < default: $collectmetrics>
Reference Files:
    -r    Reference fasta file                             < default: $reference >
    -d    dbSNP vcf file                                   < default: $dbsnp >
    -g    1000genome vcf file                              < default: $g1000 >
    -m    The Mills gold standard vcf file                 < default: $Mills >
    -P    bwa index files                                  < default: $refPre >
Misc:
    -t    Number of thread use                             < default: $thread >
          NOTE: Programme will dynamically reduce number
          of thread used to the prefered optimum
    -h    To display this help message'

while getopts i:l:n:1:2:r:d:t:g:m:b:G:s:p:P:k:w:h opt; do
	case $opt in
	n)
		sampleName=$OPTARG
		;;
	1)
		read1=$OPTARG
		;;
	2)
		read2=$OPTARG
		;;
	r)
		reference=$OPTARG
		;;
	d)
		dbsnp=$OPTARG
		;;
	g)
		g1000=$OPTARG
		;;
	m)
		mills=$OPTARG
		;;
	G)
		gatk=$OPTARG
		;;
	b)
		bwa=$OPTARG
		;;
	p)
		picards=$OPTARG
		;;
	P)
		refPre=$OPTARG
		;;
	s)
		samtools=$OPTARG
		;;
	t)
		thread=$OPTARG
		;;
	k)
		platform=$OPTARG
		;;
	i)
		id=$OPTARG
		;;
	l)
		library=$OPTARG
		;;
	w)
                wkdir=$OPTARG
                ;;
	h)
		printf '%s\n' "$help"
		exit 0
		;;
	
  esac
done

shift $((OPTIND - 1))

checkError="0";
if [ -z "$read1" ]
then
	echo "Please provide the forward read"
	checkError="1"
fi
if [ -z "$read2" ]
then
	echo "Please provide the reverse read"
	checkError="1"
fi
if [ -z "$sampleName" ]
then
	echo "Please provide the Sample name"
	checkError="1"
fi
if [ "$checkError" -eq "1" ]
then 
	echo "=======================================\n"

	printf '%s\n' "$help"
	exit -1
fi

# Add by Jacob ===============================================================================================================

cd $wkdir
mkdir $sampleName
cd $sampleName
#============================================================================================================================



currentTime=`date`
echo [$currentTime]\ Start alignment and sorting
sortThread=$(($thread-2))
if [ "$sortThread" -le "0" ]
then  sortThread=1
fi

##$bwa mem -M -t $thread -R "@RG\tID:$id\tPL:$platform\tPU:"$sampleName"_$processDay\tSM:$sampleName" $refPre $read1 $read2 | $samtools view -bSh - > $sampleName.bam && 

#$bwa mem -M -t $thread -R "@RG\tID:$id\tPL:$platform\tPU:"$sampleName"_$processDay\tSM:$sampleName" $refPre $read1 $read2 | $samtools view -bSh - > $sampleName.bam &&

#currentTime=`date`
#echo [$currentTime]\ Finish alignment 

#currentTime=`date`
#echo [$currentTime]\ Start sorting
#$samtools sort -o $sampleName.sorted.bam -@ $thread $sampleName.bam > $sampleName"_"$processDay"_"sorting.log 2<&1
#currentTime=`date`
#echo [$currentTime]\ Finish sorting

#currentTime=`date`
#echo [$currentTime]\ Start indexing
#$samtools index $sampleName.sorted.bam > $sampleName"_"$processDay"_"index.log 2>&1 &&
#currentTime=`date`
#echo [$currentTime]\ Finish indexing

#currentTime=`date` &&
#echo [$currentTime]\ Start MarkingDuplicates &&
#$java -jar -Xmx16g $picard MarkDuplicates INPUT=$sampleName.sorted.bam OUTPUT=$sampleName.sorted.dedup.bam METRICS_FILE=$sampleName.duplicates REMOVE_DUPLICATES=TRUE ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=TRUE  > $sampleName"_"$processDay"_"dedup.log 2>&1 &&
#echo [$currentTime]\ Finish MarkingDuplicates &&

#currentTime=`date` &&
#echo [$currentTime]\ Start BQSR &&
#$java -jar -Xmx16g $gatk -T BaseRecalibrator -R $reference -l INFO -I $sampleName.sorted.dedup.bam -knownSites $dbsnp -o $sampleName.recalibration_report.table -nct $thread > $sampleName"_"$processDay"_"bqsr.log 2>&1 &&
#currentTime=`date` &&
#echo [$currentTime]\ Finish BQSR &&

#currentTime=`date` &&
#echo [$currentTime]\ Start  PrintReads &&
#$java -jar -Xmx16g $gatk -T PrintReads -R $reference -l INFO -I $sampleName.sorted.dedup.bam -BQSR $sampleName.recalibration_report.table -o $sampleName.sorted.dedup.recal.bam -nct $thread  > $sampleName"_"$processDay"_"print.log 2>&1 &&
#currentTime=`date` &&
#echo [$currentTime]\\tFinished reducing bam file, now try to calculate the metrics for target region &&

#currentTime=`date` &&
#echo [$currentTime]\ Start Collect HS Metrics &&
#$java -jar $picard CollectHsMetrics I=$sampleName.sorted.dedup.recal.bam o=$sampleName.metrics.txt R=$reference BAIT_INTERVALS=$PicardBed TARGET_INTERVALS=$PicardBed > $sampleName"_"$processDay"_"collecthsmetrics.log 2>&1 &&
#currentTime=`date` &&
#echo [$currentTime]\ Finish Collect HS Metrics &&

#rm $sampleName.bam
#rm $sampleName.sorted.bam
#rm $sampleName.sorted.bam.bai
#rm $sampleName.sorted.dedup.bam
#rm $sampleName.sorted.dedup.bai

#currentTime=`date` &&
#echo [$currentTime]\ Start HaplotypeCaller &&
#$java -jar -Xmx15g $gatk -T HaplotypeCaller -l INFO -R $reference -I $sampleName.sorted.dedup.recal.bam --emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 --dbsnp $dbsnp -o $sampleName.on_target.raw.snps.indels.g.vcf -nct $thread -L $PicardBed > $sampleName"_"$processDay"_"on_target.HaplotypeCaller.log 2>&1 &&
#currentTime=`date` &&
#echo [$currentTime]\ Analysis completed, final output: $sampleName.on_target.raw.snps.indels.g.vc &&

#https://software.broadinstitute.org/gatk/documentation/article?id=3893
#Note that versions older than 3.4 require passing the options --variant_index_type LINEAR --variant_index_parameter 128000 to set the correct index strategy for the output gVCF.

currentTime=`date` &&
echo [$currentTime]\ Start HaplotypeCaller woL && 
$java -jar -Xmx47g $gatk -T HaplotypeCaller -l INFO -R $reference -I $sampleName.sorted.dedup.recal.bam --emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 --dbsnp $dbsnp -o $sampleName.woL.raw.snps.indels.g.vcf -nct $thread > $sampleName"_"$processDay"_"woL.HaplotypeCaller.log 2>&1 &&

currentTime=`date` &&
echo [$currentTime]\ Analysis completed, final output: $sampleName.woL.raw.snps.indels.g.vcf &&
echo [$currentTime]\ Finish HaplotypeCaller with Agilent_Sureselect_HumanV6 probe regions and woL 
