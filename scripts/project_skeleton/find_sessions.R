# Identify discrete listening sessions

# Load libs
libs <- c("tidyverse", "patchwork", "lubridate", "RColorBrewer", "pals", "ggridges", "viridis", "Seurat", "SCpubr")
lapply(libs, require, character.only = T)
rm(libs)


# Load data
person <- 'brian_gural'
df <- read.csv(paste0("~/data/raw/", person, "/extended_clean.csv"))


# Find gaps in play time
# Assume a >30 minute gap is a new session
# group into sessions
df.small <- df %>%
  #mutate(endTime = lubridate::ymd_hms(endTime), date = lubridate::date(endTime)) %>%
  subset(!is.na(endTime)) %>% # Convert to datetime object
  arrange(endTime) %>%  # Sort by endTime to ensure proper calculation
  mutate(next_endTime = lead(endTime, order_by = endTime),
         next_msPlayed = lead(msPlayed),
         time_gap = as.numeric(difftime(next_endTime, endTime, units = "secs")) -
           (next_msPlayed / 1000)) %>%
  ungroup() %>%
  mutate(session_id = cumsum(is.na(time_gap) | time_gap > 900))

# Find number of times an artist was played in each session
song_session_counts <- df.small %>%
  group_by(session_id, artistName) %>%
  summarise(total_plays = sum(percent_listened)) %>%
  ungroup()

# Find artists that were played > 10 times
top_artists <- song_session_counts |> 
  group_by(artistName) |> 
  summarize(total_plays = sum(total_plays)) |> 
  filter(total_plays > 10) |> 
  pull(artistName) 

# Subset to top artists
song_session_counts <- song_session_counts |> 
    filter(artistName %in% top_artists)


# Make a 'sparse' matrix
song_session_matrix <- song_session_counts %>%
  tidyr::spread(key = session_id, value = total_plays, fill = 0) 

# Format with song id as rownames
expression_matrix <- as.matrix(song_session_matrix[, -1])
rownames(expression_matrix) <- song_session_matrix$artistName

# Remove unused objects
rm(song_session_matrix)
rm(song_session_counts)
gc()

# Get metadata
session_metadata <- df.small %>%
  #subset(session_id %in% colnames(expression_matrix)) %>% 
  #group_by(session_id) %>%
  group_by(date) %>%
  summarise(
    median_endTime = median((endTime)),
    duration = sum(msPlayed)/(1000*60),  # Sum in minutes
    time_of_day = median(hour),
    day_of_week = lubridate::wday(median(endTime), label = TRUE),
    year = median(year)
  ) %>% 
  column_to_rownames(var = "date")

# Convert to Seurat
seurat_obj <- CreateSeuratObject(
  counts = expression_matrix,
  project = "SpotifyListening",
  meta.data = session_metadata
)


```{r QC on seurat}
# Standard preprocessing workflow
seurat_obj <- ScaleData(seurat_obj)
seurat_obj <- NormalizeData(seurat_obj)
seurat_obj <- FindVariableFeatures(seurat_obj)
seurat_obj <- ScaleData(seurat_obj)
seurat_obj <- RunPCA(seurat_obj)

# Cluster the cells
seurat_obj <- FindNeighbors(seurat_obj)
seurat_obj <- FindClusters(seurat_obj, resolution = 1)

# Find optimal # PCs with elbow
# Determine percent of variation associated with each PC
pct <- seurat_obj[["pca"]]@stdev / sum(seurat_obj[["pca"]]@stdev) * 100
# Calculate cumulative percents for each PC
cumu <- cumsum(pct)
# Determine which PC exhibits cumulative percent greater than 90% and % variation associated with the PC as less than 5
co1 <- which(cumu > 90 & pct < 5)[1]
# Determine the difference between variation of PC and subsequent PC
co2 <- sort(which((pct[1:length(pct) - 1] - pct[2:length(pct)]) > 0.1), decreasing = T)[1] + 1
pcs <- min(co1, co2)

# Run non-linear dimensional reduction (UMAP/tSNE)
seurat_obj <- RunUMAP(seurat_obj, dims = 1:pcs)


seurat_obj$clusters <- Idents(seurat_obj)
# Visualization
DimPlot(seurat_obj, group.by = "seurat_clusters")


```

```{r plot features}
VlnPlot(seurat_obj, "median_endTime")
FeaturePlot(seurat_obj, "Lorde")

```


```{r find markers}
sce <- seurat_obj |> 
  as.SingleCellExperiment(assay = "RNA") |>
  as("SummarizedExperiment")

# Add track names
rownames(sce) <- rownames(seurat_obj@assays$RNA@counts)

# Get markers based on expression ratios between clusters and 1vAll comparisons

sce.markers  <- scran::findMarkers(sce, groups = Idents(seurat_obj), pval.type = "all", direction = "up")


.getMarkers <- function(type){
  marker <- sce.markers@listData[[type]] |>
    as.data.frame() |> 
    #subset(p.value == 0) |>
    arrange(FDR) |>
    slice_head(n = 10) |>
    dplyr::select(p.value, FDR, summary.logFC) |>
    mutate(celltype = type) |> 
    rownames_to_column(var = "gene")
  return(marker)}


all.markers <- lapply(levels(Idents(seurat_obj)), function(x){.getMarkers(x)}) |>
  purrr::reduce(full_join) %>% 
  left_join(df %>% 
              select(spotify_track_uri, trackName, artistName) %>%
              distinct(), 
            by = c("gene" = "spotify_track_uri"))

# Now all.markers_with_info will have additional columns for trackName and artistName

all.markers |>
  group_by(celltype) |>
  arrange(desc(summary.logFC)) |>
  slice_head(n = 5) %>% 
  select(-gene) #%>% 
write.csv("~/data/temp.csv")

```