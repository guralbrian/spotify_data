#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 4:00:00
#SBATCH --mem=8g
#SBATCH -n 1
#SBATCH --output=logs/spotify_analysis_%A_%a.out
#SBATCH --error=logs/spotify_analysis_%A_%a.err

# Calculate start and end index for each array job
start_index=501
end_index=3600

module load r r/4.2.1

# Run the R script with the start and end index as arguments
Rscript scripts/api/artist_api.R $start_index $end_index
