#!/bin/bash

#path to input file (bam fafter realignment around indels)
INPUT='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/Output/422_15_11.sorted.dedupped.indelrealigned.addedreadgroups.bam'

#path to output file (bam fafter realignment around indels)
OUTPUT='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/Output/BaseRecalibratorFirstRun/422_15_11.sorted.dedupped.indelrealigned.recal_data.table'

#path to known indels
INDELS='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/ReferenceFiles/mm10.FVBN.INDELS.vcf'

#path to known SNPs
SNPS='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/ReferenceFiles/mm10.FVBN.SNPs.vcf'

#path to reference fasta
REF_FASTA='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/ReferenceFiles/mm10.fa'

#path to jarfile
JARFILE='/Users/Christian/Documents/Forskerlinja/DMBA-indusert/Sequencing/Frameworks/GenomeAnalysisTK-3.5/GenomeAnalysisTK.jar'

java -jar $JARFILE \
-T BaseRecalibrator \
-R $REF_FASTA \
-I $INPUT \
-knownSites $SNPS \
-knownSites $INDELS \
-o $OUTPUT