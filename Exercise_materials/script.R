# title:          "AMBIENT-BD - Participant Tracking"
# purpose:        "View participant progress and recruitment numbers"
# date:           ""
# author:         ""

library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)
library(RColorBrewer)
library(lubridate)
library(gt)

# Create colour palette
pal <- c(brewer.pal(12, "Paired"), brewer.pal(8, "Dark2"))

# Get the current date in YYYY-MM-DD format
todays_date <- format(Sys.Date(), "%Y-%m-%d")

# --------------------------------------------------------------------------------------------------------------
# Load in Data
# --------------------------------------------------------------------------------------------------------------

directory <- read_excel("Exercise_materials/Participant_directory.xlsx")

# --------------------------------------------------------------------------------------------------------------
# Create categories for recruitment status
# --------------------------------------------------------------------------------------------------------------

#Create dataframe with column for Withdrawn
recruitment <- data.frame(
  Withdrawn = ifelse(directory$Status %in% c("Withdrawn after baseline"), "Yes", "No")
)

# Based on Status categorise
recruitment$track <- with(directory,
          ifelse(Status %in% c("Phoned no answer", "Emailed not phoned", "Changed mind", "Ineligible", "DNA", "Not euthymic", "Contact scheduled", "Withdrawn after screening"), "Contacted",
          ifelse(Status %in% "Booked for screening", "Screening",
          ifelse(Status %in% "Booked for baseline", "Baseline",
          ifelse(Status %in% c("Baseline complete", "Participation paused", "Withdrawn after baseline"), "Consented", NA)))))

# Remove rows if track = NA
recruitment <- recruitment[!is.na(recruitment$track), ]

#Factor track as levels to keep the order we want
recruitment$track <- factor(recruitment$track, levels = c("Contacted", "Recontact", "Screening", "Baseline", "Consented"))

# --------------------------------------------------------------------------------------------------------------
# Create categories for source of referral
# --------------------------------------------------------------------------------------------------------------

# Add other columns from the directory
recruitment$referral <- directory$"Referral from"
recruitment$date_contact <- directory$"Date approached"
recruitment$date_baseline <- directory$"Date of baseline"

# If referral column is NA call it unknown
recruitment$referral[is.na(recruitment$referral)] <- "Unknown"

# Group referral categories
recruitment <- recruitment %>%
  mutate(referral = case_when(
    referral == "Bipolar Scotland Conference" ~ "Bipolar Scotland",
    referral == "CMH Network" ~ "Other",
    referral == "CPN" ~ "CMHT", 
    referral == "LinkedIn" ~ "Other",
    referral == "SubSleep" ~ "Other",
    referral == "Psychiatrist" ~ "CMHT",
    referral == "AMBIENT LEAP (WP5)" ~ "Other",
    referral == "Social Media" ~ "Other",
    referral == "MetPsy" ~ "Other",
    TRUE ~ referral
  ))

#Factor referral as levels to keep the order we want
recruitment$referral <- factor(recruitment$referral, levels = c("Bipolar Edinburgh", "Bipolar Scotland", "Mental Health Network", "Primary Care Network", "CMHT", "HELIOS-BD", "SHARE", "Wix", "Other", "Unknown"))

# --------------------------------------------------------------------------------------------------------------
# Calculate accumulated totals for each recruitment status
# --------------------------------------------------------------------------------------------------------------

recruitment <- recruitment %>%
  mutate(
    accumulate_contact = case_when(
      track %in% c("Contacted", "Screening", "Baseline", "Consented", "Recontact") ~ "Contacted",
      TRUE ~ track
    ),
    accumulate_screening = case_when(
      track %in% c("Screening", "Baseline", "Consented") ~ "Screening",
      TRUE ~ NA_character_
    ),
    accumulate_baseline = case_when(
      track %in% c("Baseline", "Consented") ~ "Baseline",
      TRUE ~ NA_character_
    ),
    accumulate_consented = case_when(
      track %in% c("Consented") ~ "Consented",
      TRUE ~ NA_character_
    )
  )

# --------------------------------------------------------------------------------------------------------------
# Prepare data for plotting
# --------------------------------------------------------------------------------------------------------------

# Reshape to long format for plotting
recruitment_long <- recruitment %>%
  pivot_longer(cols = starts_with("accumulate"), names_to = "category", values_to = "accumulated") %>%
  filter(!is.na(accumulated))

#Factor track as levels to keep the order we want
recruitment_long$accumulated <- factor(recruitment_long$accumulated, levels = c("Contacted", "Recontact", "Screening", "Baseline", "Consented", "Withdrawn"))

# --------------------------------------------------------------------------------------------------------------
# Plot - Recruitment Status
# --------------------------------------------------------------------------------------------------------------

# Calculate total counts for each status
recruitment_counts <- recruitment %>%
  group_by(track) %>%
  summarise(total = n())

# Accumulate counts
recruitment_counts <- recruitment_counts %>%
  mutate(accumulated = case_when(
    track == "Contacted" ~ total + sum(total[track %in% c("Screening", "Baseline", "Consented", "Withdrawn", "Recontact")]),
    track == "Screening" ~ total + sum(total[track %in% c("Baseline", "Consented")]),
    track == "Baseline" ~ total + total[track == "Consented"],
    TRUE ~ total
  ))

# Add withdrawn counts
recruitment_counts <- recruitment_counts %>%
  bind_rows(tibble(
    track = "Withdrawn",
    total = sum(recruitment$Withdrawn == "Yes", na.rm = TRUE),
    accumulated = sum(recruitment$Withdrawn == "Yes", na.rm = TRUE)
  ))

# Plot with counts on top
recruitment_status <-
ggplot(recruitment_long, aes(x = accumulated, fill = referral)) +
  geom_bar() +
  theme_minimal() +
  geom_text(data = recruitment_counts, aes(x = track, y = accumulated, label = accumulated), vjust = -0.5, color = "black", inherit.aes = FALSE) +
  labs(title = "Recruitment Status", x = "Status", y = "Cumulative Count", fill = "Referral") +
  scale_fill_manual(values = pal) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
  )

# Additional layer for Withdrawn = "Yes"
recruitment_status <- recruitment_status + 
  geom_bar(data = recruitment %>% filter(Withdrawn == "Yes"), 
           aes(x = "Withdrawn", fill = referral), 
           position = "stack", 
           stat = "count")


print(recruitment_status)

# Save Plot
ggsave(paste0("Recruitment_Status_", todays_date, ".png"), plot = recruitment_status, width = 10, height = 6)

# --------------------------------------------------------------------------------------------------------------
# Plot months - completed baseline
# --------------------------------------------------------------------------------------------------------------

#format dates as month and year and then by factor
recruitment_long <- recruitment_long %>%
  mutate(date_baseline = as.Date(date_baseline, format = "%Y-%m-%d")) %>%
  mutate(date_baseline = format(date_baseline, "%B %Y")) %>%
  mutate(date_baseline = factor(date_baseline, levels = unique(date_baseline[order(as.Date(paste0("01 ", date_baseline), format = "%d %B %Y"))])))

# Summarize consented counts by month
consented_counts <- recruitment_long %>%
  filter(accumulated == "Consented") %>%
  group_by(date_baseline) %>%
  summarise(consented_total = n()) %>%
  arrange(date_baseline) %>%
  mutate(cumulative_consented = cumsum(consented_total))

#add column for target (11 per month)
consented_counts <- consented_counts %>%
  arrange(date_baseline) %>%
  mutate(target = seq(11, by = 11, length.out = n()))

# Plot
recruited_cumulative_month <-
ggplot(consented_counts, aes(x = date_baseline, y = cumulative_consented)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_line(aes(y = target, group = 1), color = "red", linetype = "dashed") +
  geom_text(aes(label = consented_total), vjust = 2.0, color = "black", size = 3) + # Text inside bars
  geom_hline(yintercept = max(consented_counts$cumulative_consented, na.rm = TRUE), color = "black", linetype = "solid") +
  geom_hline(yintercept = max(consented_counts$target, na.rm = TRUE), color = "black", linetype = "solid") +
  theme_minimal() +
  labs(title = "Recruited Participants Per Month", x = "Baseline Month", y = "Cumulative Count") +
  scale_y_continuous(breaks = seq(0, max(consented_counts$target, na.rm = TRUE), by = 5)) +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
  )

print(recruited_cumulative_month)

# Save Plot
ggsave(paste0("Recruited_per_month_", todays_date, ".png"), plot = recruited_cumulative_month, width = 10, height = 6)
