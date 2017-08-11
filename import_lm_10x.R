library(readr)
library(dplyr, warn.conflicts = FALSE)

fix_names <- function(df) {
    names(df) <- tolower(names(df))
    df
}

fix_date <- function(date) {
    as.Date(as.character(date), format="%Y%m%d")
}

lm_10k <-
    read_csv("data/LM_10X_Summaries_2016.csv.gz") %>%
    fix_names() %>%
    mutate(filing_date = fix_date(filing_date),
           fye = fix_date(fye))

# Push data to database ----
library(RPostgreSQL)
pg <- dbConnect(PostgreSQL())
tablename = "lm_10x_summaries"
schema <- "lm"

rs <- dbWriteTable(pg, c(schema, tablename), lm_10k,
                   overwrite=TRUE, row.names=FALSE)
rs <- dbGetQuery(pg, paste0("ALTER TABLE ", schema, ".", tablename,
                           " OWNER TO ", schema))
rs <- dbGetQuery(pg, paste0("GRANT SELECT ON TABLE ", schema, ".", tablename,
                           " TO ", schema, "_access"))

rs <- dbGetQuery(pg, paste0("VACUUM ", schema, ".", tablename))

sql <- paste0("COMMENT ON TABLE ", schema, ".", tablename, " IS
    'CREATED USING import_lm_10x.R ON ", Sys.time() , "'")

rs <- dbGetQuery(pg, sql)
rs <- dbDisconnect(pg)
