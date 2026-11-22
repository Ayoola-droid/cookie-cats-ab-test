# retention_test.R
# The A/B test: did moving the gate from level 30 to 40 change retention?
# Compares day-1 and day-7 retention between the groups, with and without
# the flagged extreme player, and saves the results for Tableau.
# Run in RStudio with the Source button, or:  Rscript src\retention_test.R

source(file.path("src", "load_data.R"))
players <- load_players()

# Runs one two-proportion test and returns one row of results.
# The difference is always gate_40 minus gate_30 (treatment minus control).
test_retention <- function(data, metric, sample_name) {
    returned <- tapply(data[[metric]], data$version, sum)
    players_n <- tapply(data[[metric]], data$version, length)
    
    result <- prop.test(
        x = c(returned[["gate_40"]], returned[["gate_30"]]),
        n = c(players_n[["gate_40"]], players_n[["gate_30"]]),
        correct = FALSE
    )
    
    rate_30 <- returned[["gate_30"]] / players_n[["gate_30"]]
    rate_40 <- returned[["gate_40"]] / players_n[["gate_40"]]
    
    data.frame(
        sample          = sample_name,
        metric          = metric,
        players_gate_30 = players_n[["gate_30"]],
        players_gate_40 = players_n[["gate_40"]],
        rate_gate_30    = round(100 * rate_30, 2),
        rate_gate_40    = round(100 * rate_40, 2),
        diff_points     = round(100 * (rate_40 - rate_30), 2),
        ci_low_points   = round(100 * result$conf.int[1], 2),
        ci_high_points  = round(100 * result$conf.int[2], 2),
        relative_change = round(100 * (rate_40 - rate_30) / rate_30, 1),
        p_value         = signif(result$p.value, 3)
    )
}

all_players <- players
without_flagged <- players[!players$extreme_rounds, ]

results <- rbind(
    test_retention(all_players, "retention_1", "all players"),
    test_retention(all_players, "retention_7", "all players"),
    test_retention(without_flagged, "retention_1", "without flagged player"),
    test_retention(without_flagged, "retention_7", "without flagged player")
)

cat("\n--- Retention by group (rates and differences in percentage points) ---\n")
print(results, row.names = FALSE)

dir.create("output", showWarnings = FALSE)
write.csv(results, file.path("output", "retention_results.csv"), row.names = FALSE)
cat("\nSaved:", file.path("output", "retention_results.csv"), "\n")
