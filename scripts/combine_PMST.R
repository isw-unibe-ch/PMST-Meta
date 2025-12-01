# Script for combining all the PMST sets into one file, reading them directly from the GitHub repositories

# Author: Sandra Auderset
# Last modified: 2025-11-12


# load packages
library(tidyverse)
library(httr)

# fetch repositories
get_pmst_repos <- function() {
  repo_url <- GET("https://api.github.com/users/PMST-Database/repos")
  repo_info <- content(repo_url)
  repos_full_names <- sapply(repo_info, function(repo) {
    return(repo[["full_name"]])
  })
  return(repos_full_names)
}

# fetch data set names
get_pmst_langs <- function() {
  repo_url <- GET("https://api.github.com/users/PMST-Database/repos")
  repo_info <- content(repo_url)
  repos_names <- sapply(repo_info, function(repo) {
    return(tolower(repo[["name"]]))
  })
  return(repos_names)
}

# get repo list and remove the repo with the supplementary materials
pmst_repos <- get_pmst_repos()
pmst_repos <- pmst_repos[! pmst_repos %in% "PMST-Database/PMST-Supplementary-Materials"]

# get names list and remove the suppl. materials
pmst_langs <- get_pmst_langs()
pmst_langs <- pmst_langs[! pmst_langs %in% "pmst-supplementary-materials"]

# read the forms file from each repo and combine into one dataframe (can be repeated for any of the data files)
get_forms <- function(repos) {
  forms_list <- map(repos, function(f) {
    forms_url <- paste0("https://raw.githubusercontent.com/", f, "/main/", pmst_langs, "_forms.csv")
    forms_df <- read_csv(forms_url)
    return(forms_df)
  })
  # bind all dataframes into one
  combined_forms_df <- bind_rows(forms_list)
  return(combined_forms_df)
}

# apply the function
forms_dataframe <- get_forms(pmst_repos)
glimpse(forms_dataframe)

# write to Supplementary Materials folder (adjust with your own filepath)
write_csv(forms_dataframe, "/Users/auderset/Documents/GitHub/PMST-Supplementary-Materials/all_forms.csv")

