SHELL := /bin/bash

.PHONY: all script1 script2 script3 script4 script5 script6 script7 script8 script9 script10 script11 script12

# run everything
pieline: script12

script1:
	bash ./scripts/1_check_fastq.sh
	touch script1

script2: script1
	bash ./scripts/2_concatenate_fastq.sh
	touch script2

script3: script2
	bash ./scripts/3_fastq_to_fasta.sh
	touch script3

script4: script3
	bash ./scripts/4_blast.sh
	touch script4

script5: script4
	bash ./scripts/5_blast_filtering.sh
	touch script5

script6: script5
	bash ./scripts/6_manual_selection.sh
	touch script6

script7: script6
	bash ./scripts/7_efetch.sh
	touch script7

script8: script7
	bash ./scripts/8_concatenate_fasta.sh
	touch script8


script9: script8
	python3 scripts/9_translation.py
	touch script9

script10: script9
	bash scripts/9_muscle_alignment.sh
	touch script10

script11: script10
	bash scripts/10_build_tree.sh
	touch script11

script12: script11
	@echo "Pipeline analysis finished"
	touch script12
