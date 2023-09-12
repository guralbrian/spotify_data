#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 8:00:00
#SBATCH --mem=8g
#SBATCH -n 1

# Get the current date
current_year=$(date +"%Y")
current_month=$(date +"%m")
current_day=$(date +"%d")

# Create the directory path
log_dir="logs/$current_year/$current_month/$current_day"

# Create the directory if it doesn't exist
mkdir -p $log_dir

# Set the output and error log paths
#SBATCH --output=$log_dir/spotify_analysis_%A_%a.out
#SBATCH --error=$log_dir/spotify_analysis_%A_%a.err

# Spotify client ID and secret from command line arguments
ind=$1
client_id=$2
client_secret=$3
attributes_file=$4

# Load R
module load r r/4.2.1

# Run the R script with the start and end index as arguments
Rscript scripts/api/add_artist_attributes.R $ind $client_id $client_secret $attributes_file
