# Create a data frame with tasks, start and end dates
tasks <- data.frame(
  Task = c("Complete Sig/innovation", "Write approach", "Edit draft", 
           "Structure presentation", "Make plots/analysis", "Send to committee",
           "Complete 1st pres. draft", "Practice",
           "Read literature",
           "Weekend 1", "Weekend 2", "Weekend 3"),
  Start = as.Date(c("2023-09-25", "2023-09-27", "2023-10-02", 
                    "2023-10-02", "2023-10-04", "2023-10-06",
                    "2023-10-09", "2023-10-13",
                    "2023-09-25",
                    "2023-10-01", "2023-10-08", "2023-10-15")),
  End = as.Date(c("2023-09-27", "2023-09-30", "2023-10-07", 
                  "2023-10-04", "2023-10-07", "2023-10-07",
                  "2023-10-13", "2023-10-19",
                  "2023-10-07",
                  "2023-10-02", "2023-10-09", "2023-10-16")),
  Type = c("Writing", "Writing", "Writing", 
           "Presentation", "Research", "Writing",
           "Presentation", "Presentation",
           "Research",
           "Weekend", "Weekend", "Weekend"),
  stringsAsFactors = FALSE
)


library(ggplot2)
library(dplyr)

# Create the Gantt chart
gantt_chart <- ggplot(subset(tasks, Type != "Weekend"), aes(xmin = Start, xmax = End, y = reorder(Task, Start, decreasing = T))) +
 geom_rect(aes(ymin = Task, ymax = Task, color = Type, fill = Type), linewidth = 14) +
  geom_text(aes(x = End, label = Task), hjust = -0.05, size = 4) +
  geom_vline(data = subset(tasks, Type == "Weekend"),
             aes(xintercept = Start), color = "grey80", size = 20, alpha = 0.2) +
 scale_color_brewer(type = "cat", palette = "Dark2") +
 scale_fill_brewer(type = "cat", palette = "Dark2") +
  labs(title = "Thesis & Oral Qual Prep Timeline") +
  theme_minimal() +
  coord_cartesian(clip = 'off') + 
  theme(
    axis.title = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.text.y = element_blank(),
    plot.margin = margin(5, 50, 5, 5),
    legend.title = element_blank(),
    legend.position = c(0.9, 0.6),
    legend.text = element_text(size = 14),
    plot.title = element_text(size = 20)
    
  )

# Show the Gantt chart
gantt_chart

