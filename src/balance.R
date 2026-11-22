# balance.R
# Checks the cleaned data and whether players were split fairly between the two groups.
# Run in RStudio with the Source button, or:  Rscript src\balance.R

source(file.path("src", "load_data.R"))
players <- load_players()

cat("\n--- 1. Retention columns after cleaning ---\n")
cat("retention_1 is now:", class(players$retention_1), "\n")
cat("retention_7 is now:", class(players$retention_7), "\n")

cat("\n--- 2. Reconcile to the raw file ---\n")
cat("Players:", nrow(players), "(raw file: 90189)\n")
cat("Came back day 1:", sum(players$retention_1), "(raw file: 40153)\n")
cat("Came back day 7:", sum(players$retention_7), "(raw file: 16781)\n")

cat("\n--- 3. Sample balance (is the split really 50/50?) ---\n")
counts <- table(players$version)
print(counts)
expected_each <- sum(counts) / 2
cat("Expected in each group if exactly 50/50:", expected_each, "\n")
cat("gate_40 has", counts[["gate_40"]] - counts[["gate_30"]], "more players than gate_30\n")
balance_test <- chisq.test(counts, p = c(0.5, 0.5))
print(balance_test)

cat("\n--- 4. Flagged extreme players ---\n")
cat("Players flagged:", sum(players$extreme_rounds), "\n")
print(players[players$extreme_rounds, ])
