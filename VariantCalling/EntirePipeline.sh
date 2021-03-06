#!/bin/bash

#Sample numbers
SAMPLE_NORMAL='422_15_11_SecondAttempt'
SAMPLE_TUMOR='422_15_2_SecondAttempt'

#Theragen Sample numbers
THERAGEN_NORMAL='826'
THERAGEN_TUMOR='825'

#Adapter sequences
INDEX_SEQUENCE_NORMAL='CGCATACA'
INDEX_SEQUENCE_TUMOR='CCGAAGTA'
LEFT_ADAPTER_SEQUENCE='GATCGGAAGAGCACACGTCTGAACTCCAGTCAC'
RIGHT_ADAPTER_SEQUENCE='ATCTCGTATGCCGTCTTCTGCTTG'

#Master path to output folder
MASTER='/data2/christian/Sequencing/Output/'

#Master path to FASTQ files
FASTQ_MASTER='/data2/christian/TBO150127_151231/01_fastq_file/TN1511D0'

#Path to known indels
INDELS='/data2/christian/Sequencing/ReferenceFiles/mm10.FVBN.INDELS.vcf'

#Path to known SNPs
SNPS='/data2/christian/Sequencing/ReferenceFiles/mm10.FVBN.SNPs.vcf'

#Path to GATK jar file
GATK_JARFILE='/data2/christian/Sequencing/Frameworks/GenomeAnalysisTK-3.5/GenomeAnalysisTK.jar'

#Path to SnpEff jarfile
SNPEFF_JARFILE='/data2/christian/Sequencing/Frameworks/SnpEff/snpEff/snpEff.jar'

#Path to SnpSift jarfile
SNPSIFT_JARFILE='/data2/christian/Sequencing/Frameworks/SnpEff/snpEff/SnpSift.jar'

#Path to folder containing Picard.jar
PICARD_PATH='/data2/christian/Sequencing/Frameworks/Picard/'

#Path to Sickle framework
SICKLE='/data2/christian/Sequencing/Frameworks/sickle/sickle'

#Path to reference FASTA
REF_FASTA='/data2/christian/Sequencing/ReferenceFiles/mm10.fa'

#Number of threads for variant calling (MuTect, nct argument)
NCT='2'

#SnpEff reference genome version
SNPEFF_REFERENCE='GRCm38.82'

#Sickle quality threshold: threshold for trimming based on average quality in a window (default=20)
QUAL=20

#Sickle length threshold: threshold to keep a read based on length after trimming (default=20)
LENGTH=50



#Path to fastq files
FASTQ_EXTENSION_1='_1.fastq'
FASTQ_EXTENSION_2='_2.fastq'
FASTQ_BETWEEN='/TN1511D0'
INPUT_FASTQ_NORMAL_1=$FASTQ_MASTER$THERAGEN_NORMAL$FASTQ_BETWEEN$THERAGEN_NORMAL$FASTQ_EXTENSION_1
INPUT_FASTQ_NORMAL_2=$FASTQ_MASTER$THERAGEN_NORMAL$FASTQ_BETWEEN$THERAGEN_NORMAL$FASTQ_EXTENSION_2
INPUT_FASTQ_TUMOR_1=$FASTQ_MASTER$THERAGEN_TUMOR$FASTQ_BETWEEN$THERAGEN_TUMOR$FASTQ_EXTENSION_1
INPUT_FASTQ_TUMOR_2=$FASTQ_MASTER$THERAGEN_TUMOR$FASTQ_BETWEEN$THERAGEN_TUMOR$FASTQ_EXTENSION_2

#Unzip fastq files. Remove if no longer necessary
UNZIP_EXTENSION='.gz'
# gunzip $INPUT_FASTQ_NORMAL_1$UNZIP_EXTENSION
# gunzip $INPUT_FASTQ_NORMAL_2$UNZIP_EXTENSION
# gunzip $INPUT_FASTQ_TUMOR_1$UNZIP_EXTENSION
# gunzip $INPUT_FASTQ_TUMOR_2$UNZIP_EXTENSION

#Names of folders needed in output folder
#cd $MASTER
#mkdir BWAmemAlignedBams
#mkdir SamSortedBams
#mkdir RealignerTargetCreator
#mkdir IndelRealigned
#mkdir BaseRecalibratorFirstRun
#mkdir BaseRecalibratorSecondRun
#mkdir AnalyzeCovariatesRecalibrationPlots
#mkdir PrintReadsRecalibrated
#mkdir MuTect2
#mkdir SnpEffAnnotated
#cd ./SnpEffAnnotated
#mkdir Summaries
#cd $MASTER
#mkdir SnpSiftFiltered
#mkdir SnpSiftExtracted
#mkdir DeduppedBams
#cd ./DeduppedBams/
#mkdir Metrics





#NORMAL


#Cutadapt trimming (CutAdapt.sh)
OUTPUT_CUTADAPT_PATH='Cutadapt/'
OUTPUT_CUTADAPT_EXTENSION_1='_1.cutadapt.fastq'
OUTPUT_CUTADAPT_EXTENSION_2='_2.cutadapt.fastq'
OUTPUT_CUTADAPT_NORMAL_1=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_NORMAL$OUTPUT_CUTADAPT_EXTENSION_1
OUTPUT_CUTADAPT_NORMAL_2=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_NORMAL$OUTPUT_CUTADAPT_EXTENSION_2

LOGOUTPUT_EXTENSION='.cutadapt.log'
LOGOUTPUT_NORMAL=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_NORMAL$LOGOUTPUT_EXTENSION

~/.local/bin/cutadapt \
-a $LEFT_ADAPTER_SEQUENCE$INDEX_SEQUENCE_NORMAL$RIGHT_ADAPTER_SEQUENCE \
-A $LEFT_ADAPTER_SEQUENCE$INDEX_SEQUENCE_NORMAL$RIGHT_ADAPTER_SEQUENCE \
-o $OUTPUT_CUTADAPT_NORMAL_1 \
-p $OUTPUT_CUTADAPT_NORMAL_2 \
$INPUT_FASTQ_NORMAL_1 $INPUT_FASTQ_NORMAL_2 > $LOGOUTPUT_NORMAL


#Remove low quality reads with Sickle (Sickle.sh)
OUTPUT_SICKLE_PATH='Sickle/'
OUTPUT_SICKLE_EXTENSION_1='_1.cutadapt.trim.fastq'
OUTPUT_SICKLE_EXTENSION_2='_2.cutadapt.trim.fastq'
OUTPUT_SICKLE_SINGLE_EXTENSION='.cutadapt.trimsingle.fastq'
OUTPUT_SICKLE_NORMAL_1=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_NORMAL$OUTPUT_SICKLE_EXTENSION_1
OUTPUT_SICKLE_NORMAL_2=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_NORMAL$OUTPUT_SICKLE_EXTENSION_2
OUTPUT_SICKLE_SINGLE_NORMAL=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_NORMAL$OUTPUT_SICKLE_SINGLE_EXTENSION

$SICKLE pe \
-t sanger \
-g \
-q $QUAL \
-l $LENGTH \
-f $OUTPUT_CUTADAPT_NORMAL_1 \
-r $OUTPUT_CUTADAPT_NORMAL_2 \
-o $OUTPUT_SICKLE_NORMAL_1 \
-p $OUTPUT_SICKLE_NORMAL_2 \
-s $OUTPUT_SICKLE_SINGLE_NORMAL


#Map read to reference genome (BWAmem.sh)
OUTPUT_BWA_PATH='BWAmemAlignedBams/'
OUTPUT_BWA_EXTENSION='.bam'
OUTPUT_BWA_NORMAL=$MASTER$OUTPUT_BWA_PATH$SAMPLE_NORMAL$OUTPUT_BWA_EXTENSION

bwa mem \
-R '@RG\tID:foo\tSM:bar\tPL:Illumina' \
-t 8 \
-k 45 \
$REF_FASTA \
$OUTPUT_SICKLE_NORMAL_1 $OUTPUT_SICKLE_NORMAL_2 > \
$OUTPUT_BWA_NORMAL


#Sort mapped reads by coordinate (SortSam.sh)
OUTPUT_SORTSAM_PATH='SamSortedBams/'
OUTPUT_SORTSAM_EXTENSION='.sorted.bam'
OUTPUT_SORTSAM_NORMAL=$MASTER$OUTPUT_SORTSAM_PATH$SAMPLE_NORMAL$OUTPUT_SORTSAM_EXTENSION

picard \
SortSam \
I=$OUTPUT_BWA_NORMAL \
O=$OUTPUT_SORTSAM_NORMAL \
SORT_ORDER=coordinate


#Mark duplicates (MarkDuplicates.sh)
OUTPUT_MARKDUPLICATES_PATH='DeduppedBams/'
OUTPUT_MARKDUPLICATES_EXTENSION='.sorted.dedupped.bam'
OUTPUT_MARKDUPLICATES_NORMAL=$MASTER$OUTPUT_MARKDUPLICATES_PATH$SAMPLE_NORMAL$OUTPUT_MARKDUPLICATES_EXTENSION

METRICS_PATH='DeduppedBams/Metrics/'
METRICS_EXTENSION='.sorted.metrics.txt'
METRICS_NORMAL=$MASTER$METRICS_PATH$SAMPLE_NORMAL$METRICS_EXTENSION

picard \
MarkDuplicates \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
REMOVE_DUPLICATES=TRUE \
I=$OUTPUT_SORTSAM_NORMAL \
O=$OUTPUT_MARKDUPLICATES_NORMAL \
M=$METRICS_NORMAL


#Create realignment targets (RealignerTargetCreator.sh)
OUTPUT_REALIGNERTARGETCREATOR_PATH='RealignerTargetCreator/'
OUTPUT_REALIGNERTARGETCREATOR_EXTENSION='.sorted.dedupped.realignment_targets.list'
OUTPUT_REALIGNERTARGETCREATOR_NORMAL=$MASTER$OUTPUT_REALIGNERTARGETCREATOR_PATH$SAMPLE_NORMAL$OUTPUT_REALIGNERTARGETCREATOR_EXTENSION

java -jar $GATK_JARFILE \
-T RealignerTargetCreator \
-R $REF_FASTA \
-I $OUTPUT_MARKDUPLICATES_NORMAL \
-known $INDELS \
-o $OUTPUT_REALIGNERTARGETCREATOR_NORMAL


#Realign around indels (IndelRealigner.sh)
OUTPUT_INDELREALIGNER_PATH='IndelRealigned/'
OUTPUT_INDELREALIGNER_EXTENSION='.sorted.dedupped.indelrealigned.bam'
OUTPUT_INDELREALIGNER_NORMAL=$MASTER$OUTPUT_INDELREALIGNER_PATH$SAMPLE_NORMAL$OUTPUT_INDELREALIGNER_EXTENSION

java -jar $GATK_JARFILE \
-T IndelRealigner \
-R $REF_FASTA \
-I $OUTPUT_MARKDUPLICATES_NORMAL \
-targetIntervals $OUTPUT_REALIGNERTARGETCREATOR_NORMAL \
-known $INDELS \
-o $OUTPUT_INDELREALIGNER_NORMAL


#Create base recalibration data table (BaseRecalibrator.sh)
RECAL_DATA_PATH='BaseRecalibratorFirstRun/'
RECAL_DATA_EXTENSION='.sorted.dedupped.indelrealigned.recal_data.table'
RECAL_DATA_NORMAL=$MASTER$RECAL_DATA_PATH$SAMPLE_NORMAL$RECAL_DATA_EXTENSION

java -jar $GATK_JARFILE \
-T BaseRecalibrator \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_NORMAL \
-knownSites $SNPS \
-knownSites $INDELS \
-o $RECAL_DATA_NORMAL


#Second base recalibration data table for recalibration plot (BaseRecalibratorSecondPass.sh)
POST_RECAL_DATA_PATH='BaseRecalibratorSecondRun/'
POST_RECAL_DATA_EXTENSION='.sorted.dedupped.indelrealigned.recal_data.post_recal_data.table'
POST_RECAL_DATA_NORMAL=$MASTER$POST_RECAL_DATA_PATH$SAMPLE_NORMAL$POST_RECAL_DATA_EXTENSION

java -jar $GATK_JARFILE \
-T BaseRecalibrator  \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_NORMAL \
-knownSites $SNPS \
-knownSites $INDELS \
-BQSR $RECAL_DATA_NORMAL \
-o $POST_RECAL_DATA_NORMAL


#Create Recalibration plot (AnalyzeCovariates.sh)
ANALYZECOVARIATES_PLOT_PATH='AnalyzeCovariatesRecalibrationPlots/'
ANALYZECOVARIATES_PLOT_EXTENSION='.sorted.dedupped.indelrealigned.recalibrationplot.pdf'
ANALYZECOVARIATES_PLOT_NORMAL=$MASTER$ANALYZECOVARIATES_PLOT_PATH$SAMPLE_NORMAL$ANALYZECOVARIATES_PLOT_EXTENSION

java -jar $GATK_JARFILE \
-T AnalyzeCovariates \
-R $REF_FASTA \
-before $RECAL_DATA_NORMAL \
-after $POST_RECAL_DATA_NORMAL \
-plots $ANALYZECOVARIATES_PLOT_NORMAL


#Recalibrate base quality score (PrintReads.sh)
RECALIBRATED_OUTPUT_PATH='PrintReadsRecalibrated/'
RECALIBRATED_OUTPUT_EXTENSION='.sorted.dedupped.indelrealigned.recalibrated.bam'
RECALIBRATED_OUTPUT_NORMAL=$MASTER$RECALIBRATED_OUTPUT_PATH$SAMPLE_NORMAL$RECALIBRATED_OUTPUT_EXTENSION

java -jar $GATK_JARFILE \
-T PrintReads \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_NORMAL \
-BQSR $RECAL_DATA_NORMAL \
-o $RECALIBRATED_OUTPUT_NORMAL





#TUMOR


#Cutadapt trimming (CutAdapt.sh)
OUTPUT_CUTADAPT_PATH='Cutadapt/'
OUTPUT_CUTADAPT_EXTENSION_1='_1.cutadapt.fastq'
OUTPUT_CUTADAPT_EXTENSION_2='_2.cutadapt.fastq'
OUTPUT_CUTADAPT_TUMOR_1=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_TUMOR$OUTPUT_CUTADAPT_EXTENSION_1
OUTPUT_CUTADAPT_TUMOR_2=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_TUMOR$OUTPUT_CUTADAPT_EXTENSION_2

LOGOUTPUT_EXTENSION='.cutadapt.log'
LOGOUTPUT_TUMOR=$MASTER$OUTPUT_CUTADAPT_PATH$SAMPLE_TUMOR$LOGOUTPUT_EXTENSION

~/.local/bin/cutadapt \
-a $LEFT_ADAPTER_SEQUENCE$INDEX_SEQUENCE_TUMOR$RIGHT_ADAPTER_SEQUENCE \
-A $LEFT_ADAPTER_SEQUENCE$INDEX_SEQUENCE_TUMOR$RIGHT_ADAPTER_SEQUENCE \
-o $OUTPUT_CUTADAPT_TUMOR_1 \
-p $OUTPUT_CUTADAPT_TUMOR_2 \
$INPUT_FASTQ_TUMOR_1 $INPUT_FASTQ_TUMOR_2 > $LOGOUTPUT_TUMOR


#Remove low quality reads with Sickle (Sickle.sh)
OUTPUT_SICKLE_PATH='Sickle/'
OUTPUT_SICKLE_EXTENSION_1='_1.cutadapt.trim.fastq'
OUTPUT_SICKLE_EXTENSION_2='_2.cutadapt.trim.fastq'
OUTPUT_SICKLE_SINGLE_EXTENSION='.cutdapt.trimsingle.fastq'
OUTPUT_SICKLE_TUMOR_1=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_TUMOR$OUTPUT_SICKLE_EXTENSION_1
OUTPUT_SICKLE_TUMOR_2=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_TUMOR$OUTPUT_SICKLE_EXTENSION_2
OUTPUT_SICKLE_SINGLE_TUMOR=$MASTER$OUTPUT_SICKLE_PATH$SAMPLE_TUMOR$OUTPUT_SICKLE_SINGLE_EXTENSION

$SICKLE pe \
-t sanger \
-g \
-q $QUAL \
-l $LENGTH \
-f $OUTPUT_CUTADAPT_TUMOR_1 \
-r $OUTPUT_CUTADAPT_TUMOR_2 \
-o $OUTPUT_SICKLE_TUMOR_1 \
-p $OUTPUT_SICKLE_TUMOR_2 \
-s $OUTPUT_SICKLE_SINGLE_TUMOR

#Map read to reference genome (BWAmem.sh)
OUTPUT_BWA_TUMOR=$MASTER$OUTPUT_BWA_PATH$SAMPLE_TUMOR$OUTPUT_BWA_EXTENSION

bwa mem \
-R '@RG\tID:foo\tSM:bar\tPL:Illumina' \
-t 8 \
-k 45 \
$REF_FASTA \
$OUTPUT_SICKLE_TUMOR_1 $OUTPUT_SICKLE_TUMOR_2 > \
$OUTPUT_BWA_TUMOR


#Sort mapped reads by coordinate (SortSam.sh)
OUTPUT_SORTSAM_TUMOR=$MASTER$OUTPUT_SORTSAM_PATH$SAMPLE_TUMOR$OUTPUT_SORTSAM_EXTENSION

picard \
SortSam \
I=$OUTPUT_BWA_TUMOR \
O=$OUTPUT_SORTSAM_TUMOR \
SORT_ORDER=coordinate


#Mark duplicates (MarkDuplicates.sh)
OUTPUT_MARKDUPLICATES_TUMOR=$MASTER$OUTPUT_MARKDUPLICATES_PATH$SAMPLE_TUMOR$OUTPUT_MARKDUPLICATES_EXTENSION

METRICS_TUMOR=$MASTER$METRICS_PATH$SAMPLE_TUMOR$METRICS_EXTENSION

picard \
MarkDuplicates \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
REMOVE_DUPLICATES=TRUE \
I=$OUTPUT_SORTSAM_TUMOR \
O=$OUTPUT_MARKDUPLICATES_TUMOR \
M=$METRICS_TUMOR


#Create realignment targets (RealignerTargetCreator.sh)
OUTPUT_REALIGNERTARGETCREATOR_TUMOR=$MASTER$OUTPUT_REALIGNERTARGETCREATOR_PATH$SAMPLE_TUMOR$OUTPUT_REALIGNERTARGETCREATOR_EXTENSION

java -jar $GATK_JARFILE \
-T RealignerTargetCreator \
-R $REF_FASTA \
-I $OUTPUT_MARKDUPLICATES_TUMOR \
-known $INDELS \
-o $OUTPUT_REALIGNERTARGETCREATOR_TUMOR


#Realign around indels (IndelRealigner.sh)
OUTPUT_INDELREALIGNER_TUMOR=$MASTER$OUTPUT_INDELREALIGNER_PATH$SAMPLE_TUMOR$OUTPUT_INDELREALIGNER_EXTENSION

java -jar $GATK_JARFILE \
-T IndelRealigner \
-R $REF_FASTA \
-I $OUTPUT_MARKDUPLICATES_TUMOR \
-targetIntervals $OUTPUT_REALIGNERTARGETCREATOR_TUMOR \
-known $INDELS \
-o $OUTPUT_INDELREALIGNER_TUMOR


#Create base recalibration data table (BaseRecalibrator.sh)
RECAL_DATA_TUMOR=$MASTER$RECAL_DATA_PATH$SAMPLE_TUMOR$RECAL_DATA_EXTENSION

java -jar $GATK_JARFILE \
-T BaseRecalibrator \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_TUMOR \
-knownSites $SNPS \
-knownSites $INDELS \
-o $RECAL_DATA_TUMOR


#Second base recalibration data table for recalibration plot (BaseRecalibratorSecondPass.sh)
POST_RECAL_DATA_TUMOR=$MASTER$POST_RECAL_DATA_PATH$SAMPLE_TUMOR$POST_RECAL_DATA_EXTENSION

java -jar $GATK_JARFILE \
-T BaseRecalibrator  \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_TUMOR \
-knownSites $SNPS \
-knownSites $INDELS \
-BQSR $RECAL_DATA_TUMOR \
-o $POST_RECAL_DATA_TUMOR


#Create Recalibration plot (AnalyzeCovariates.sh)
ANALYZECOVARIATES_PLOT_TUMOR=$MASTER$ANALYZECOVARIATES_PLOT_PATH$SAMPLE_TUMOR$ANALYZECOVARIATES_PLOT_EXTENSION

java -jar $GATK_JARFILE \
-T AnalyzeCovariates \
-R $REF_FASTA \
-before $RECAL_DATA_TUMOR \
-after $POST_RECAL_DATA_TUMOR \
-plots $ANALYZECOVARIATES_PLOT_TUMOR


#Recalibrate base quality score (PrintReads.sh)
RECALIBRATED_OUTPUT_TUMOR=$MASTER$RECALIBRATED_OUTPUT_PATH$SAMPLE_TUMOR$RECALIBRATED_OUTPUT_EXTENSION

java -jar $GATK_JARFILE \
-T PrintReads \
-R $REF_FASTA \
-I $OUTPUT_INDELREALIGNER_TUMOR \
-BQSR $RECAL_DATA_TUMOR \
-o $RECALIBRATED_OUTPUT_TUMOR


#Call variants (MuTect.sh)
MUTECT_PATH='MuTect2/'
MUTECT_EXTENSION='.vcf'
MUTECT_OUTPUT=$MASTER$MUTECT_PATH$SAMPLE_TUMOR$MUTECT_EXTENSION

java -jar $GATK_JARFILE \
-T MuTect2 \
-R $REF_FASTA \
-I:tumor $RECALIBRATED_OUTPUT_TUMOR \
-I:normal $RECALIBRATED_OUTPUT_NORMAL \
--dbsnp $SNPS \
-nct $NCT \
-o $MUTECT_OUTPUT


#Annotate with SnpEff (SnpEff.sh)
SNPEFF_PATH='SnpEffAnnotated/'
SNPEFF_EXTENSION='.annotated.vcf'
SNPEFF_OUTPUT=$MASTER$SNPEFF_PATH$SAMPLE_TUMOR$SNPEFF_EXTENSION

SNPEFF_STATS_PATH='SnpEffAnnotated/Summaries/'
SNPEFF_STATS_EXTENSION='.summary.html'
SNPEFF_STATS_OUTPUT=$MASTER$SNPEFF_STATS_PATH$SAMPLE_TUMOR$SNPEFF_STATS_EXTENSION

java -Xmx4g -jar $SNPEFF_JARFILE \
$SNPEFF_REFERENCE \
-v -stats $SNPEFF_STATS_OUTPUT \
$MUTECT_OUTPUT > \
$SNPEFF_OUTPUT


#Filter annotated VCF for variants passing MuTect filters (SnpSiftForPass.sh)
SNPSIFT_PATH='SnpSiftFiltered/'
SNPSIFT_EXTENSION='.annotated.passfiltered.vcf'
SNPSIFT_OUTPUT=$MASTER$SNPSIFT_PATH$SAMPLE_TUMOR$SNPSIFT_EXTENSION

cat $SNPEFF_OUTPUT | java -jar $SNPSIFT_JARFILE \
filter "(FILTER='PASS')" \
> $SNPSIFT_OUTPUT


#Extract pass filtered vcf to  text file (SnpSiftExtract.sh)
SNPEXTRACT_PATH='SnpSiftExtracted/'
SNPEXTRACT_EXTENSION='.annotated.passfiltered.extracted.vcf'
SNPEXTRACT_OUTPUT=$MASTER$SNPEXTRACT_PATH$SAMPLE_TUMOR$SNPEXTRACT_EXTENSION

java -jar $SNPSIFT_JARFILE \
extractFields \
-s "," \
$SNPSIFT_OUTPUT \
'CHROM' 'POS' 'ID' 'QUAL' 'ANN[*].GENE' 'ANN[*].ALLELE' 'ANN[*].EFFECT' \
'ANN[*].IMPACT' 'ANN[*].GENEID' > $SNPEXTRACT_OUTPUT
