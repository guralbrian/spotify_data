# Makefile for running R scripts in sequence

# Location of your data files
RAW_DATA = data/raw/brian_gural/extended_raw.csv
CLEAN_DATA = data/raw/brian_gural/extended_clean.csv

# Targets
all: visualize

# Run json_to_df_extended.R only if extended_raw.csv does NOT exist
$(RAW_DATA):
	Rscript scripts/project_skeleton/json_to_df_extended.R

# Run clean_extended.R only if extended_clean.csv does NOT exist
$(CLEAN_DATA): $(RAW_DATA)
	Rscript scripts/project_skeleton/clean_extended.R

# Run visualize_extended.R only if extended_clean.csv exists
visualize: $(CLEAN_DATA)
	Rscript scripts/project_skeleton/visualize_extended.R

# Phony targets
.PHONY: all visualize
