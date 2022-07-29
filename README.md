# Research Project Tempalte (DS-ECON) 🔬 

**Thanks for subscribing to [ds-econ.com](https://www.ds-econ.com)!** 🎉
> Haven't subscribed yet? Do so [here!](https://www.ds-econ.com/#/portal/signup/free)

This is a R based template for writing papers and compiling slides. [It follows the "One year to dissertate"" post by Lucy D'Agostino McGowan](https://livefreeordichotomize.com/2018/09/14/one-year-to-dissertate/).

Make sure to set up your own GitHub repository for your writing project! Simply click **"Use this Template" above!**

## How to use it?
- Write your text in the `.Rmd` files for the different chapters of your paper. You can use text, code, and your code's output (see [bookdown](https://bookdown.org) for more information)
- **Compile your document / slides** by executing: `source("./scripts/compile.R")` / `source("./scripts/compile_slides.R")`
  - If you want to make use of separate R scripts for generating your output, make sure to call them in `./scripts/analysis.R`
  - There's also the option to **send** a specific chapter as a word file **to Google Drive** (useful when sharing with colleagues) see: `.scripts/send-to-drive.R`
- Store papers in the `literature` sub-folder and data in the `data` sub-folder
  - Place your **citations as a bibtex file** in `./assets/citations/citations.bib`
  - If you use R Studio & Zotero: The [Visual Editor](https://www.rstudio.com/blog/exploring-rstudio-visual-markdown-editor/) will sync with your Zotero library so you can easily implement citations
- Suggestion: You can use the same R objects in both your paper and your slides. Hence, there will be no trouble of using an outdated plot in your slides or similar.
  
## Options
- Edit `./tex/params.tex` with your name, title, etc.
- Adapt `./tex/preamble.tex` to adjust the formatting of the document
- Adapt `./tex/beamer_preamble.tex` to adjust the formatting of the slides
- You can specify the order and which chapters to include in `_bookdown.yml`
- If you want to add general code chunk options and edit attributes of the R Markdown YAML header: You can do so in `index.Rmd`.
