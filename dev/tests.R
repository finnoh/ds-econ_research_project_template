require(httr)
require(jsonlite)
require(dplyr)
require(rtweet)
library(openssl)
library(httpuv)
library(hansard)
library(tidytext)
library(lubridate)
library(htm2txt)
library(rvest)
library(xml2)
library(stringr)
library(progressr)
library(pdftools)
library(tidyverse)

### bill

# Requesting all publications after a given date
y <- bill_publications(ID = 752025)
y <- all_answered_questions(start_date = "2017-01-01")
x <- early_day_motions(
  edm_id = NULL,
  session = NULL,
  start_date = "1900-01-01",
  end_date = Sys.Date(),
  signatures = 1,
  extra_args = NULL,
  tidy = TRUE,
  tidy_style = "snake",
  verbose = TRUE
)
x$war <- ifelse(x$title %>% tolower() %>%  str_detect("crisis"), 1, 0)
x$year <- x$date_tabled_value %>% year()


x %>% group_by(year) %>% summarise(war = sum(war)) %>% ggplot(aes(x = year, y = war)) + geom_line()


####


handlers(global = TRUE)
handlers("rstudio")


bearer_token <- Sys.getenv("BEARER_TOKEN")
headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))

params <- list(`user.fields` = 'description',
               `expansions` = 'pinned_tweet_id')

handle <- 'nytimes'
url_handle <- sprintf('https://api.twitter.com/2/users/by?usernames=%s', handle)
url <- "https://twitter.com/TwitterDev/status/1228393702244134912"

response <-
  httr::GET(url = url,
            httr::add_headers(.headers = headers),
            query = params)
obj <- httr::content(response, as = "text")
print(obj)

json_data <- fromJSON(obj, flatten = TRUE) %>% as.data.frame
View(json_data)

# whatever name you assigned to your created app
appname <- "Master theses"

## api key (example below is not a real key)
key <- "gglGxb9FpBG3uljFFz2ki8pHK"

## api secret (example below is not a real key)
secret <- "x3kcIvXsmKFcHnSM8tgRhr8zMhKdq8D5KjnFWLnm8m36l4v7dw"

access_token <- "1482632535767195652-tWHRAJWlwaIqbHatWXgMMkbWSumsqD"
access_secret <- "PHbypaHsU33XbMPLsegrqJh3fU5PdVGfjwncP4RxcvKZ3"

# create token named "twitter_token"
twitter_token <- create_token(
  app = appname,
  consumer_key = key,
  consumer_secret = secret,
  access_token = access_token,
  access_secret = access_secret)


# hansards


# get all links on series level
url <- 'https://api.parliament.uk/historic-hansard/volumes/index.html'
pg <- read_html(url)
subpages_page_full<- html_attr(html_nodes(pg, "a"), "href")

bool_series <- str_detect(subpages_page_full, pattern = "/historic-hansard/volumes/\\d")
url_series <- subpages_page_full[bool_series]

# get all links to pages on "volume" level
url <- 'https://api.parliament.uk/historic-hansard/volumes/1/index.html'
pg <- read_html(url)

subpages_series_full <- html_attr(html_nodes(pg, "a"), "href")
bool_volumes <- str_detect(subpages_series_full, pattern = "/historic-hansard/volumes")
url_volume <- subpages_series_full[bool_volumes]

url_volume
# get all links to pages on "columns" level
url <- paste0('https://api.parliament.uk/', url_volume[1])
pg <- read_html(url)

subpages_volume_full <- html_attr(html_nodes(pg, "a"), "href")
bool_lords_commons <- str_detect(subpages_volume_full, pattern = "(/historic-hansard/commons)|(/historic-hansard/lords)")
url_columns <- subpages_volume_full[bool_lords_commons]
url_columns

get_url_volume <- function(url_series) {
  
  p <- progressr::progressor(along=url_volume)
  url <- paste0('https://api.parliament.uk', url_series)
  # get all links to pages on "volume" level
  pg <- read_html(url)
  
  # subpages of the series url
  subpages_series_full <- html_attr(html_nodes(pg, "a"), "href")
  bool_volumes <- str_detect(subpages_series_full, pattern = "/historic-hansard/volumes")
  
  # filter links to the different volumes
  url_volume <- subpages_series_full[bool_volumes]
  p()
  return(url_volume)
}

get_url_column <- function(url_volume) {
  
  # get all links to pages on "columns" level
  url <- paste0('https://api.parliament.uk/', url_volume)
  print(url)
  pg <- read_html(url)
  
  subpages_volume_full <- html_attr(html_nodes(pg, "a"), "href")
  bool_lords_commons <- str_detect(subpages_volume_full, pattern = "(/historic-hansard/commons)|(/historic-hansard/lords)")
  
  # filter for column urls
  url_columns <- subpages_volume_full[bool_lords_commons]
  
  
  
  return(url_columns)
}

create_text_data_frame <- function(url_loop) {
  
  # progress bar
  p <- progressr::progressor(along=url_loop)
  
  # loop over the available urls for the text
  text <- lapply(url_columns[1:100], function(x){
    gettxt(paste0('https://api.parliament.uk/', x))
    p()
  })
  
  # store in tmp dataframe
  tmp <-
    tibble(url = paste0('https://api.parliament.uk/', url_columns[1:100]),
           text = text)
  
  # extract information from the url
  tmp2 <-
    tmp$url %>% str_remove(pattern = "https://api.parliament.uk//historic-hansard/") %>%
    str_split(pattern = "/", simplify = TRUE) %>% as_tibble()
  tmp3 <- tmp2$V5 %>% str_split(pattern = "#", simplify = TRUE)
  colnames(tmp2) <- c("house", "year", "month", "day", "drop")
  
  # create dataframe
  df_speeches <-
    tibble(
      house = tmp2$house,
      year = tmp2$year,
      month = tmp2$month,
      day = tmp2$day,
      title = tmp3,
      text = tmp$text
    )
  
  return(df_speeches)
}

#### Web scraper

# get all links on series level
url <- 'https://api.parliament.uk/historic-hansard/volumes/index.html'
pg <- read_html(url)
subpages_page_full<- html_attr(html_nodes(pg, "a"), "href")

bool_series <- str_detect(subpages_page_full, pattern = "/historic-hansard/volumes/\\d")
url_series <- subpages_page_full[bool_series]

list_url_volumes <- lapply(url_series, get_url_volume)

# init volume storage
list_url_columns <- list()

# select a series
storage <- list()
# loop over all the volumes of a series and stores the columns
with_progress(for (s in seq_along(list_url_volumes)) {
  p <- progressr::progressor(along=list_url_volumes)
  series <- list_url_volumes[[s]]
  p()
  for (v in seq_along(series)) {
    storage[[v]] <- get_url_column(series[v])
  }
})


url_loop <- url_columns[1:100]
df_speeches <- create_data_frame(url_loop = url_loop)

# scraping pdf files directly
# 'https://hansard.parliament.uk/pdf/commons/2022-01-05'

setwd("/Users/hoener/Documents/dev/master_thesis")

all_dates <- seq(ymd("1802-01-01"), ymd("2021-12-31"), by = "days")

url_commons <- paste0('https://hansard.parliament.uk/pdf/commons/', all_dates)
url_lords <- paste0('https://hansard.parliament.uk/pdf/lords/', all_dates)

scrape_hansard <- function(urls, name) {
  p <- progressr::progressor(along=urls)
  
  for (u in seq_along(urls)) {
    file_name <- paste0("./data", "/", name, "/", all_dates[u], ".pdf")
    print(file_name)
    print(urls[u])
    try(download.file(url_commons[u], destfile = file_name, mode = "wb"))
    p()
  }
  
}

download.file(url, destfile = "./data/pdf_files/sample.pdf", mode = "wt")


## hansard api
# get ids via /overview/pdfsforday.{format}

get_next_house_date <- function(house, date){
  url <- paste0("https://hansard-api.parliament.uk/overview/linkedsittingdates.json?date=", date, "&house=", house)
  obj <- httr::GET(url)
  tmp <- rawToChar(obj$content) %>% jsonlite::fromJSON()
  return(tmp[['NextSittingDate']])
}

get_house_dates <- function(house, from="1802-01-01", to="2021-12-31"){
  
  url <-
    paste0(
      "https://hansard-api.parliament.uk/historicsittingdays?queryParams.house=",
      house,
      "&queryParams.startDate=",
      from,
      "&queryParams.endDate=",
      to, "&queryParams.take=100"
    )
  obj <- httr::GET(url)
  tmp <- rawToChar(obj$content) %>% jsonlite::fromJSON()
  dates <- tmp[['Item']]['Results'] %>% as.data.frame() %>% select(Results.SittingDate)
  
  return()
}

get_id <- function(house, date) {
  
  # get the ids for a specific day
  url <- paste0("https://hansard-api.parliament.uk/overview/pdfsforday.json?date=", date,"&house=", house)
  obj <- httr::GET(url)
  tmp <- rawToChar(obj$content) %>% jsonlite::fromJSON() %>% as.data.frame()
  ids <- unique(tmp$SectionExternalId)
  
  # return unique, non NA ids
  return(ids[!(is.na(ids))])
}

get_debate <- function(id, date, house) {
  
  # make the api call
  url <- paste0("https://hansard-api.parliament.uk/debates/debate/", id, ".json")
  obj <- httr::GET(url)
  tmp <- rawToChar(obj$content) %>% jsonlite::fromJSON()
  
  # store the text
  texts <- tmp[["Items"]][["Value"]] %>% as.data.frame()
  colnames(texts) <- "text"
  
  # additional information
  texts$hrs_tag <- tmp[["Items"]][["HRSTag"]]
  texts$external_id <- tmp[["Items"]][["ExternalId"]]
  texts$item_type <- tmp[["Items"]][["ItemType"]]
  texts$member_id <- tmp[["Items"]][["MemberId"]]
  texts$attirbuted_to <- tmp[["Items"]][["AttributedTo"]]
  texts$hansard_section <- tmp[["Items"]][["HansardSection"]]
  texts$date <- date
  texts$house <- house
  
  return(texts)
}

wrapper_api_call <- function(house, start, end) {
  
  interval <- seq(ymd(start), ymd(end), by = "days")
  debate <- list()
  store_dates <- rep(NA, length(interval))
  
  # loop over the dates in the interval
  debates <- lapply(interval, function(x) {
    ids <- get_id(house = house, date = x)
    
    lapply(ids, function(y) {
      get_debate(y, date = x, house = house)
    })
    
  }) 
  
  # loop over all ids on a specific date

    

  return(debates %>% dplyr::bind_rows())
}

house <- "commons"
date <- "2022-01-17"

dates <- get_house_dates(house = "commons")
ids <- get_id(house=house, date=date)
test <- get_debate(ids[1], date = date, house = house)

#debates <- wrapper_api_call(house = "commons", start = "1970-01-01", end = "1980-01-01")
debates <- wrapper_api_call(house = "commons", start = "2022-01-01", end = "2022-01-18")
debates_para <- debates %>% filter(hrs_tag == "hs_Para") %>% 
  unnest_tokens(word, text) %>% anti_join(stop_words)

words_time <- debates_para %>% count(word, date)

words_time %>% filter(word == "government") %>% 
  ggplot(aes(x = date, y = n)) + geom_line()

debates_para %>% sample_n(1000) %>% ggplot(aes(x = word)) + geom_histogram(stat = "count")

# get the debated for these ids

######

defence <- research_briefings(topic = "Defence")
df <- defence %>% select(abstract_value, topic, date_value, identifier_value)
df_text <- df %>% unnest_tokens(word, abstract_value) %>% anti_join(stop_words)
df_text$datetime <- df_text$date_value %>% parse_date_time(orders = "ymd HMS")
df_text$date <- df_text$datetime %>% date()

df_freq <- df_text %>% group_by(date) %>% count(word, sort = TRUE)
df_freq %>% filter(word == "nuclear") %>% ggplot(aes(x=date, y=n)) + geom_line()

