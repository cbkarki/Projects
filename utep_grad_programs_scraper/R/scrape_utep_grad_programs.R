# ============================================================
# Script: scrape_utep_grad_programs.R
# Purpose: Scrape UTEP Graduate Programs from the online catalog
# Author: Chitra Karki
# Date: 2025-09-02
# ============================================================

# load required library 
library(rvest)        # web scraping
library(dplyr)        # data manipulation
library(purrr)        # functional programming
library(stringr)      # string manipulation
library(writexl)      # export excel files

# catalog URL
url = "https://catalog.utep.edu/degreeprograms/"

# load HTML page
page = read_html(url)

# Extract all <a> tags
a_tags = page %>% 
    html_nodes("a")

# filter links containing "/grad/"
grad_links = a_tags %>%
    keep(~ {
        href = html_attr(.x, "href")
        !is.na(href) && str_detect(href, "^/grad/")
    })

# extract program information
grad_programs = map_dfr(grad_links, function(link) {
    
    # program title
    title = link %>% html_node(".title") %>% html_text(trim = TRUE)
    
    # program URL
    href = html_attr(link, "href")
    
    # extract college and department from URL path
    path_parts = str_split(str_remove(href, "^/grad/"), "/", simplify = TRUE)
    
    data.frame(
        Program = title,
        URL = paste0("https://catalog.utep.edu", href),
        College = if (ncol(path_parts) >= 1) path_parts[1] else NA,
        Department = if (ncol(path_parts) >= 2) path_parts[2] else NA,
        stringsAsFactors = FALSE
    )
})

# preview data
head(grad_programs)

# writing output as .xlsx file
writexl::write_xlsx(grad_programs,"data/programs_utep_web_scraping.xlsx")
