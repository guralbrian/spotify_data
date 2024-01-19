person=["brian_gural"]
rule all:
    input: 
    "data_private/raw/individuals/{person}/extended/MyData/extended_raw.csv",
rule json_extended: 
    input: "data_private/raw/individuals/{person}/extended/MyData/{year}.json"
    output: "data_private/raw/individuals/{person}/extended/MyData/extended_raw.csv"
    run: "Rscript scripts/load_data/json_to_df_extended.R {person}"