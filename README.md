# Heathrow "Mystery Meat" analysis pipeline  
This analysis pipeline takes raw FASTQ files and ... [FINISH]

## Requirements  
- `micromamba` installation  (see: https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html). To install, execute the following and restart your shell:

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

- NCBI taxonomy dump is required to run this pipeline as `taxonkit` is used in script 5 (see: https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/). Please download and extract with the following before running:

```bash
mkdir -p ~/.taxonkit

# download latest NCBI taxonomy dump
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

# extract
tar -xzf taxdump.tar.gz

mv *.dmp *.prt readme.txt ~/.taxonkit/
```

# Step 1: Setting up the pipeline environment
Creating and activating the `micromamba` environment is recommended to ensure reproducibility

```bash
# clone this repo and navigate into project root
git clone git@github.com:archiebenn/BIOLM0051_analysis.git
cd BIOLM0051_analysis

# create project environment
micromamba create -n mystery-meat-env -f environment.yml

# activate project environment
micromamba activate mystery-meat-env
```

Ensure all scripts are executable with the following:
```
chmod +x scripts/*
```

# Step 2: Running the scripts  
> [!IMPORTANT]
> Please run all scripts from the project root.

## Option A - Run Full Pipeline with `run_pipeline.sh`
Execute all scripts in the correct order for this pipeline: 

```bash
./scripts/run_pipeline.sh
```

Example run:

```
./scripts/run_pipeline.sh 

   __  _____  _____________________  __    __  __________ ______    ___   _  _____   ____  ______________
  /  |/  /\ \/ / __/_  __/ __/ _ \ \/ /   /  |/  / __/ _ /_  __/   / _ | / |/ / _ | / /\ \/ / __/  _/ __/
 / /|_/ /  \  /\ \  / / / _// , _/\  /   / /|_/ / _// __ |/ /     / __ |/    / __ |/ /__\  /\ \_/ /_\ \  
/_/  /_/   /_/___/ /_/ /___/_/|_| /_/   /_/  /_/___/_/ |_/_/     /_/ |_/_/|_/_/ |_/____//_/___/___/___/  
                                                                                                                                                                                                         

[1] FASTQ check beginning...
[1] FASTQ check complete

[2] FASTQ concatenation beginning...
Concatenating sampleA files...
Concatenating sampleB files...
.
.
.
[11] Phylogenetic tree builds complete. Find tree files in results/10_tree_files
Full analysis runtime: 00h:24m:31s 
```

## Option B - Run pipeline from a specific script -> end with  
`run_pipeline.sh <script-number>`
This was introduced to allow users to skip lengthy steps of the pipeline as the full results folder is already provided here on GitHub.  
For example, to run the analysis in full, but starting after the BLAST script (script 4 - which can take > 30 minutes): 
```bash
./scripts/run_pipeline.sh 5
   __  _____  _____________________  __    __  __________ ______    ___   _  _____   ____  ______________
  /  |/  /\ \/ / __/_  __/ __/ _ \ \/ /   /  |/  / __/ _ /_  __/   / _ | / |/ / _ | / /\ \/ / __/  _/ __/
 / /|_/ /  \  /\ \  / / / _// , _/\  /   / /|_/ / _// __ |/ /     / __ |/    / __ |/ /__\  /\ \_/ /_\ \  
/_/  /_/   /_/___/ /_/ /___/_/|_| /_/   /_/  /_/___/_/ |_/_/     /_/ |_/_/|_/_/ |_/____//_/___/___/___/  

[5] Filtering BLAST hits...
Splitting sampleA back into parts, sorting by staxid, adding taxonomic lineages, and manually selecting BLAST hits.
Splitting sampleB back into parts, sorting by staxid, adding taxonomic lineages, and manually selecting BLAST hits.
.
.
.
[11] Phylogenetic tree builds complete. Find tree files in results/10_tree_files
Full analysis runtime: 00h:24m:31s 
```

