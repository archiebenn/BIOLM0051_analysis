# Heathrow "Mystery Meat" analysis pipeline
### Requirements  
If you wish to reproduce this analysis, the following are recommended:
- `micromamba` installation  (see: [https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html])

Setting up the `micromamba` environment below is recommended to ensure reproducibility by ensuring the same packages and package versions are installed.

### Step 1: Setting up and activating the virtual Environment
- Clone this repo onto your local machine and navigate into this directory.  
- Set up the project environment using the provided `environment.lock.yml` file for an exact environment reproduction with pinned versions of packages (linux only), or the `environment.yml` file for a more portable setup across operating systems
```bash
micromamba create -n BIOLM0051-env -f environment.lock.yml  # (or environment.yml)
micromamba activate BIOLM0051-env
```
