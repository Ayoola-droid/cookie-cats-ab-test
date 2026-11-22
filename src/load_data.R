# load_data.R
# Reads the raw Cookie Cats file and returns a cleaned copy in memory.
# The raw file on disk is never changed.
# Other scripts use it with:  source(file.path("src", "load_data.R"))

load_players <- function(raw_path = file.path("data", "raw", "cookie_cats.csv")) {
    
    if (!file.exists(raw_path)) {
        stop("Cannot find ", raw_path, ". Open the project (cookie-cats-ab-test.Rproj) first.")
    }
    
    players <- read.csv(raw_path, stringsAsFactors = FALSE)
    
    # 1. Check the expected columns are there
    expected_cols <- c("userid", "version", "sum_gamerounds", "retention_1", "retention_7")
    missing_cols <- setdiff(expected_cols, names(players))
    if (length(missing_cols) > 0) {
        stop("Missing columns: ", paste(missing_cols, collapse = ", "))
    }
    
    # 2. Turn retention text ("True"/"False") into real TRUE/FALSE values
    for (col in c("retention_1", "retention_7")) {
        as_text <- toupper(as.character(players[[col]]))
        bad <- !(as_text %in% c("TRUE", "FALSE"))
        if (any(bad)) {
            stop(col, " has ", sum(bad), " values that are not True or False")
        }
        players[[col]] <- as_text == "TRUE"
    }
    
    # 3. Check there are only the two test groups, with gate_30 (control) first
    bad_groups <- setdiff(unique(players$version), c("gate_30", "gate_40"))
    if (length(bad_groups) > 0) {
        stop("Unexpected groups: ", paste(bad_groups, collapse = ", "))
    }
    players$version <- factor(players$version, levels = c("gate_30", "gate_40"))
    
    # 4. Flag (do not delete) players with impossible-looking round counts.
    #    The next highest after the one extreme player is 2,961 rounds.
    players$extreme_rounds <- players$sum_gamerounds > 10000
    
    players
}
