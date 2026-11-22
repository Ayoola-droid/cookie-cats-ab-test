# inspect_raw.R
# First look at the raw Cookie Cats A/B test file.
# It only reads the file and prints facts about it. It changes nothing.
# Run from the project folder:  Rscript src\inspect_raw.R

raw_path <- file.path("data", "raw", "cookie_cats.csv")

if (!file.exists(raw_path)) {
    stop("Cannot find ", raw_path, ". Check you are in the project folder and the file is in data\\raw.")
}

players <- read.csv(raw_path, stringsAsFactors = FALSE)

cat("\n--- 1. Shape ---\n")
cat("Rows:", nrow(players), "\n")
cat("Columns:", ncol(players), "\n")

cat("\n--- 2. Column names and types ---\n")
str(players)

cat("\n--- 3. First 5 rows ---\n")
print(head(players, 5))

cat("\n--- 4. Missing values per column ---\n")
print(colSums(is.na(players)))

cat("\n--- 5. Duplicate player IDs ---\n")
cat("Duplicated userid values:", sum(duplicated(players$userid)), "\n")

cat("\n--- 6. Players in each test group ---\n")
group_counts <- table(players$version)
print(group_counts)
cat("Share of players (%):\n")
print(round(100 * prop.table(group_counts), 2))

cat("\n--- 7. Game rounds played (sum_gamerounds) ---\n")
print(summary(players$sum_gamerounds))
cat("Players who never played a round:", sum(players$sum_gamerounds == 0), "\n")
cat("Five highest values:", head(sort(players$sum_gamerounds, decreasing = TRUE), 5), "\n")

cat("\n--- 8. Retention values as stored ---\n")
cat("retention_1:\n")
print(table(players$retention_1, useNA = "ifany"))
cat("retention_7:\n")
print(table(players$retention_7, useNA = "ifany"))
