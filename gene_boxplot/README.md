# Gene Boxplot GUI
Creates images based on search terms inputed by the user. 

## gui.ipynb
The main file. Queries the database, creates plots, then stitches them into a final plot, located in the images subdirectory. User input is:

mode: Should be one of 'Summary', 'name', 'symbol', 'GO'. Caps matter.
search_term: A string you want to search for in the column mode
max_stitch: How many images in one row for the final image.
outputName: What you want to name the outputfile.

## all_cells_tpm.csv
The database which we query from. Contains TPM information for each gene, along with GO terms and summaries from Flybase. 

## images subdirectory
This is where your output is located.

# More relevant if you want to redo with different data.

## combiner.R
Creates 'all_cells_tpm.csv', which is the database used to query the search terms. If RNA seq data is changed, combiner.R should be changed appropriately and re-run. 

## rsemFiles directory
Contains RSEM files (".genes.results") used in the creation of all_cells_tpm.csv.

## best_gene_summary_fb_2023_04.tsv
Contains summaries for FBGN terms. Get from Flybase website. Used in combiner.R

# Less relevant things

## temp subdirectory
Temporary directory where the images go before being stitched together. 

## deprecated subdirectory
Old code.

