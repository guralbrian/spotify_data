#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 2:00:00
#SBATCH --mem=2g
#SBATCH -n 1
#SBATCH --output=logs/spotify_analysis_%A_%a.out
#SBATCH --error=logs/spotify_analysis_%A_%a.err
#SBATCH --array=1-5

# Calculate start and end index for each array job
start_index=$(( ($SLURM_ARRAY_TASK_ID - 1) * 100 + 1 ))
end_index=$(( $SLURM_ARRAY_TASK_ID * 100 ))

module load r r/4.2.1

# Run the R script with the start and end index as arguments
Rscript scripts/api/artist_api.R $start_index $end_index
