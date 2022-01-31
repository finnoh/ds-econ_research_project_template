# run the sandbox code
source("./scripts/analysis.R")

print("Analysis finished - start compiling the paper \n") 
print("Render slides \n")

# render and open slides
rmarkdown::render("presentation.Rmd")
system('open "presentation.pdf"')