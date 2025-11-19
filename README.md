# Heathrow "Mystery Meat" analysis pipeline
### Requirements  
If you wish to reproduce this analysis, the following are required:
- `micromamba` installation  (see: [https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html]). To install, execute the following and restart your shell:

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

- NCBI taxonomy dump is required to run this pipeline as `taxonkit` is used in script 5 (see: [https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/]). Please download and extract with the following before running:

```bash
mkdir -p ~/.taxonkit

# download
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

# extract
tar -xzf taxdump.tar.gz

mv *.dmp *.prt readme.txt ~/.taxonkit/
```

### Step 1: Setting up and activating the virtual Environment
- Recommended to ensure reproducibility by ensuring the same packages and package versions are installed.
- Clone this repo onto your local machine and navigate into this directory.  
- Set up the project environment using the provided `environment.lock.yml` file for an exact environment reproduction with pinned versions of packages (linux only), or the `environment.yml` file for a more portable setup across operating systems
```bash
micromamba create -n BIOLM0051-env -f environment.yml  # (or environment.lock.yml)
micromamba activate BIOLM0051-env
```

### Step 2: Running the scripts  
#### Make executable 
Ensure all the scripts in this repository are executable locally with the following:
```bash
chmod +x scripts/*
```
#### 2.1 `run_all.sh`
Run the following from the project root to execute all script in the correct order for this pipeline: 
```bash
scripts/run_all.sh
```
This will produce results folders during the execution which can all be viewed once the analysis has finished.
