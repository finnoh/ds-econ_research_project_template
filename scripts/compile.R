# run the sandbox code
source("./scripts/analysis.R")
print("Analysis finished - start compiling the paper \n") 

# write packages to bib files
knitr::write_bib(file="./assets/citations/packages.bib", prefix = "R-pkg_")

# render and open book
bookdown::render_book("index.Rmd")
system('open "./_book/paper.pdf"')
