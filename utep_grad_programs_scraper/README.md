# UTEP Graduate Programs Web Scraper

## Project Overview
This project scrapes the University of Texas at El Paso (UTEP) online graduate 
catalog to extract information about graduate programs. The output includes 
program names, URLs, colleges, and departments in a structured Excel format. 
This dataset can be used for academic analytics, reporting, or research purposes.

## Features
- Extracts all graduate program links from the UTEP catalog.
- Parses program names, full URLs, associated colleges, and departments.
- Outputs results in Excel format for easy analysis.
- Written in R using `rvest`, `dplyr`, `purrr`, `stringr`, and `writexl`.


## How to run
1. Clone this repository
```bash
git clone https://github.com/cbkarki/utep_grad_programs_scraper.git
cd utep-grad-programs-scraper
```

2. Open R or Rstudio
3. Install required packages (if not already installed):
```r
install.packages(c("rvest", "dplyr", "purrr", "stringr", "writexl"))
```

4. Run the script

```r
source("R/scrape_utep_grad_programs.R")
```

5. Check the results
The Excel file will be saved at:
```bash
data/programs_utep_web_scraping.xlsx
```

## Example Output

| Program                           | URL                                                                                    | College            | Department                     |
| --------------------------------- | -------------------------------------------------------------------------------------- | ------------------ | ------------------------------ |
| Master of Science in Data Science | [https://catalog.utep.edu/grad/datascience](https://catalog.utep.edu/grad/datascience) | College of Science | Department of Computer Science |

## License

This project is licensed undet MIT License. See LICENSE file for details 

## Contact 


Chitra Karki - [GitHub](https://github.com/cbkarki) | [Email](mailto:cbkarki@miners.utep.edu)



