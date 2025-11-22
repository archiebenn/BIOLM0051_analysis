# Heathrow "Mystery Meat" analysis pipeline
### Requirements  
If you wish to reproduce this analysis, the following are required:
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

### Step 1: Setting up and activating the virtual Environment
- Recommended to ensure reproducibility by ensuring the same packages are installed when running this pipeline.
- Clone this repo onto your local machine and navigate into this project directory.  
- Set up the project environment using the provided `environment.yml` file:
```bash
micromamba create -n mystery-meat-env -f environment.yml
micromamba activate mystery-meat-env
```

### Step 2: Running the scripts  
Please run all scripts from the project root.
#### Make executable 
Ensure the scripts in this repository are executable locally with the following:
```bash
chmod +x scripts/*
```
#### `run_pipeline.sh`
Run the following to execute all script in the correct order for this pipeline: 
```bash
./scripts/run_pipeline.sh
```
Below is an example of how `run_pipeline.sh` looks when running:  
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

```
This will produce results folders during the execution which can all be viewed once the analysis has finished.
