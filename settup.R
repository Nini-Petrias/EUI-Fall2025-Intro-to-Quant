# install.packages(c("fs","glue","rmarkdown","gert"))  # run if needed
library(fs)
library(glue)
library(rmarkdown)
library(gert) #- this is for auto commit to git

# ---------- settings you can tweak ----------
weeks <- sprintf("week%02d", 1:10)       # make 10 weeks
site_title <- "Lab" #name 
theme_bs <- 3    # 3 or 4 for bsplus #might need to change to bootstrap_ver <- 3
# -------------------------------------------

# 0) sanity: run from the repo root
stopifnot(dir_exists(".")) # this not included in new

# 1) write _site.yml at repo root
navbar_entries <- paste0(
  "    - text: \"", sub("^week0?", "Week ", weeks), "\"\n",
  "      href: ", weeks, "/index.html\n",
  collapse = ""
)

site_yml <- glue(
  'name: "course-site"
output_dir: "docs"

output:
  html_document:
    toc: true
    toc_float: true
    code_folding: show
    self_contained: false
    bootstrap_version: {theme_bs}

navbar:
  title: "{site_title}"
  left:
{navbar_entries}'
)

writeLines(site_yml, "_site.yml")




# 2) Week template (tabset + bsplus carousel)
rmd_tmpl <- paste0(
  '---
title: "WEEK_TITLE"
---

```{r setup, include=FALSE}
library(bsplus); library(htmltools); library(magrittr)
bsplus::use_bs_carousel()

Tabs {.tabset}
Section A

Content.

Section B

More content.

Carousel
bs_carousel(id = "car", use_indicators = TRUE, use_controls = TRUE) %>%
  bs_append(tags$img(src = "images/img1.png"), caption = "One") %>%
  bs_append(tags$img(src = "images/img2.png"), caption = "Two")
  
  ')

# 3) Scaffold weeks

for (w in weeks) {
  dir_create(w)
  dir_create(path(w, "images"))
  
# placeholder images so the carousel renders
  
  if (!file_exists(path(w, "images", "img1.png"))) {
    png(path(w, "images", "img1.png"), width = 600, height = 350)
    plot.new(); text(.5, .5, paste("Placeholder:", toupper(w), "img1.png"))
    dev.off()
  }
  if (!file_exists(path(w, "images", "img2.png"))) {
    png(path(w, "images", "img2.png"), width = 600, height = 350)
    plot.new(); text(.5, .5, paste("Placeholder:", toupper(w), "img2.png"))
    dev.off()
  }
  
  rmd <- gsub("WEEK_TITLE", gsub("^week0?", "Week ", w), rmd_tmpl, fixed = TRUE)
  writeLines(rmd, path(w, "index.Rmd"))
}

# 4) Optional landing page
if (!file_exists("index.Rmd")) {
  writeLines(
    '---
title: "Lab Homepage"

Welcome. Pick a week from the navbar above.',
    "index.Rmd")
}

#5) Build the site to docs/
  
  message("Rendering site to docs/ ...")
rmarkdown::render_site(encoding = "UTF-8")

#6) Make sure GitHub Pages doesn’t mangle site_libs

file_create(path("docs", ".nojekyll"))

message("\nScaffold complete. In GitHub → Settings → Pages: Source = main, Folder = /docs.\n")


#to commit changes
gert::git_init()

gert::git_config_set("user.name",  "Nini-Petrias")
gert::git_config_set("user.email", "nipetriashvili7@gmail.com")

gert::git_add(".")

# Commit
gert::git_commit("Update W1")



#Have not used these commands but could use them for pushing

# First-time push: add remote and set upstream, if not set
# (Use your real repo URL)
#gert::git_remote_add(name = "origin",
 #                    url  = "https://github.com/Nini-Petrias/EUI-Fall2025-Intro-to-Quant.git")

# Push current branch to main (or whatever your default is)
#gert::git_push(remote = "origin", refspec = "HEAD:refs/heads/main")