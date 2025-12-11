# Script for combining all the PMST sets into one file, reading them directly from the GitHub repositories

# Author: Sandra Auderset
# Last modified: 2025-12-09


# load packages
library(tidyverse)
library(httr)

# fetch repositories
get_pmst_repos <- function() {
  repo_url <- GET("https://api.github.com/users/isw-unibe-ch/repos")
  repo_info <- content(repo_url)
  repos_full_names <- sapply(repo_info, function(repo) {
    return(repo[["full_name"]])
  })
  return(repos_full_names)
}

# fetch data set names
get_pmst_langs <- function() {
  repo_url <- GET("https://api.github.com/users/isw-unibe-ch/repos")
  repo_info <- content(repo_url)
  repos_names <- sapply(repo_info, function(repo) {
    return(tolower(repo[["name"]]))
  })
  return(repos_names)
}

# get repo list and remove the repo with the supplementary materials
pmst_repos <- get_pmst_repos()
pmst_repos <- pmst_repos[! pmst_repos %in% "isw-unibe-ch/PMST-Meta"]

# get names list and remove the suppl. materials
pmst_langs <- get_pmst_langs()
pmst_langs <- pmst_langs[! pmst_langs %in% "pmst-meta"]

# read the forms file from each repo and combine into one dataframe (can be repeated for any of the data files)
get_forms <- function(repos) {
  forms_list <- map2(repos, pmst_langs, function(r, l) {
    forms_url <- paste0("https://raw.githubusercontent.com/", r, "/main/", l, "_forms.csv")
    forms_df <- read_csv(forms_url, cols(.default = "c"), col_names = TRUE)
    return(forms_df)
  })
  # bind all dataframes into one and re-order the columns
  combined_forms_df <- bind_rows(forms_list)
  return(combined_forms_df)
}

# apply the function 
forms_dataframe <- get_forms(pmst_repos) %>%
  select(language_id, form_id:analysed_orth_form, source, page, ends_with("_tag"))
glimpse(forms_dataframe)

# write to Supplementary Materials folder (adjust with your own filepath)
write_csv(forms_dataframe, "/Users/auderset/Documents/GitHub/PMST-Meta/all_forms.csv")


# same for cells to get an overview of scenarios
# read the cells file from each repo and combine into one dataframe (can be repeated for any of the data files)
get_cells <- function(repos) {
  cells_list <- map2(repos, pmst_langs, function(r, l) {
    cells_url <- paste0("https://raw.githubusercontent.com/", r, "/main/", l, "_cells.csv")
    cells_df <- read_csv(cells_url, cols(.default = "c"), col_names = TRUE)
    return(cells_df)
  })
  # bind all dataframes into one and re-order the columns
  combined_cells_df <- bind_rows(cells_list)
  return(combined_cells_df)
}

# apply the function 
cells_dataframe <- get_cells(pmst_repos) %>%
  select(-language_id) %>%
  distinct()
glimpse(cells_dataframe)

# write to Supplementary Materials folder (adjust with your own filepath)
write_csv(cells_dataframe, "/Users/auderset/Documents/GitHub/PMST-Meta/all_cells.csv")


