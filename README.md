#Mouse Exome Sequencing

This is a repository to document my work in setting up a pipeline for mouse exome sequencing. It is for my research use, but may act as a guideline for anyone looking to do accomplish the same goal. Most documents here are simple bash implementations of existing frameworks. The pipeline is mostly an implementation of the Broad Institutes's best practices for variant calling as presented [here](https://www.broadinstitute.org/gatk/guide/best-practices.php).

The exome sequencing data used for this project was generated at the TheragenEtex Insitute in South Korea, using an Illumina HiSeq and the Agilent SureSelect All Mouse All Exon Kit. 


##Required Frameworks

###Genome Analysis Toolkit
As the name implies, the Genome Analysis Toolkit (GATK) is a framework for analysing sequencing data, including exome sequencing. The primary use of GATK in this pipeline is for the mutation calling itself, using the MuTect command. GATK is created by the Broad Institute, and can be downloaded [here](https://www.broadinstitute.org/gatk/download/). Login is required to download. All work presented here is using the Genome Analysis Toolkit version 3.5

###Java
Java is required for almost all frameworks listed, and can be downloaded [here](https://java.com/en/download/). All work presented here is running Java build 1.8.

###Burrows-Wheeler Aligner
Burrows-Wheeler Aligner is a framework which allows us to align reads in the FASTQ format to .bam files. It can be downloaded from [here](http://bio-bwa.sourceforge.net/). All work presented here is using BWA version 0.7.12.

###Picard
Picard is a toolkit for manipulating sequence data formats, including BAM/SAM/CRAM and VCF. It is also created by the Broad Institute, and can be downloaded [here](http://broadinstitute.github.io/picard/). All work presented here is using Picard version 2.0.1.

###Samtools
Samtools is another toolkit for manipulating and viewing sequence data formats, and can be downloaded [here](http://www.htslib.org/). All work presented here is using Samtools version 1.3.

###TwoBitToFa
Framework for converting .2bit files to .fa (fasta) files, created by UCSC, and can be downloaded for Mac/OSX [here](http://hgdownload.cse.ucsc.edu/admin/exe/macOSX.x86_64/) (filename twoBitToFa).



1) Raw reads FASTQ file -> Cutadapt/Sickle
	DONE BY THERAGEN

2) Map reads to produce BAM file 
	DONE BY USING:		./Scripts/MapReadsWithBWAmem.sh
	REFERENCE FILE: 	./ReferenceFiles/mm10.fa
	WITH FRAMEWORK:		./Frameworks/bwa-0.7.12/	:	mem

3 Realign BAM file by coordinate
	DONE BY USING: 		./Scripts/SortSam.sh
	With Framework:		./Frameworks/Picard/		:	SortSam

4) Dedup files using MarkDuplicates
	DONE BY USING:		./Scripts/MarkDuplicatesPicard.sh
	WITH FRAMEWORK:		./Frameworks/Picard/		:	MarkDuplicates

5) Create Realigner Target 		- not tested
	DONE BY USING:		./Scripts/RealignerTargetCreator.sh
	REFERENCE FILE: 	./ReferenceFiles/mm10.fa
	SNP FILE: 		./RefeferenceFiles/2012-0612-snps+indels_FVBNJ_annotated_reordered.vcf
	WITH FRAMEWORK:		./Frameworks/GenomeAnalysisTK-3.5 : GenomeAnalysisTK.jar	-T RealignerTargetCreator

6) Realign around indels		- not tested
	DONE BY USING:		./Scripts/IndelRealigner.sh
	REFERENCE FILE: 	./ReferenceFiles/mm10.fa
	SNP FILE: 		./RefeferenceFiles/2012-0612-snps+indels_FVBNJ_annotated_reordered.vcf
	WITH FRAMEWORK:		./Frameworks/GenomeAnalysisTK-3.5 : GenomeAnalysisTK.jar	-T IndelRealigner

7) Call variants
	DONE BY USING: 		./Scripts/muTectScript.sh
	REFERENCE FILE:		./ReferenceFiles/mm10.fa
	SNP FILE: 		./RefeferenceFiles/2012-0612-snps+indels_FVBNJ_annotated_reordered.vcf
	WITH FRAMEWORK:		./Frameworks/GenomeAnalysisTK-3.5 : GenomeAnalysisTK.jar	-T MuTect2

8) Annotate VCF
	DONE BY USING:		./Scripts/annotateWithSnpEff.sh
	REFERENCE:		GRCm38.82
	WITH FRAMEWORK:		./Frameworks/SnpEff/		:	snpEff.jar

9) Filter VCF
	DONE BY USING: 		./Scripts/SnpSiftForPass.sh
	WITH FRAMEWORK:		./Frameworks/SnpEff/		:	SnpSift.jar








If necessary:
Reorder BAM to reference file
	DONE BY USING:		./Scripts/reorderBamToReference.sh
	REFERENCE FILE:		./ReferenceFiles/mm10.fa
	WITH FRAMEWORK:		./Frameworks/Picard/	:	dist/picard.jar			-ReorderSam
