# bootstrap.R
# Checks the retention result a second way: resample each group's players
# many times, recalculate retention each time, and see how much the gap moves.
# Saves every draw for the Tableau chart.
# Run in RStudio with the Source button, or:  Rscript src\bootstrap.R

source(file.path("src", "load_data.R"))
players <- load_players()

set.seed(2026)      # makes the random draws the same every time you run it
n_draws <- 2000

group_30 <- players[players$version == "gate_30", ]
group_40 <- players[players$version == "gate_40", ]
n_30 <- nrow(group_30)
n_40 <- nrow(group_40)

draws <- data.frame(
    draw                = seq_len(n_draws),
    retention_1_gate_30 = NA_real_,
    retention_1_gate_40 = NA_real_,
    retention_7_gate_30 = NA_real_,
    retention_7_gate_40 = NA_real_
)

for (i in seq_len(n_draws)) {
    pick_30 <- sample(n_30, n_30, replace = TRUE)
    pick_40 <- sample(n_40, n_40, replace = TRUE)
    draws$retention_1_gate_30[i] <- 100 * mean(group_30$retention_1[pick_30])
    draws$retention_1_gate_40[i] <- 100 * mean(group_40$retention_1[pick_40])
    draws$retention_7_gate_30[i] <- 100 * mean(group_30$retention_7[pick_30])
    draws$retention_7_gate_40[i] <- 100 * mean(group_40$retention_7[pick_40])
}

draws$diff_day_1 <- draws$retention_1_gate_40 - draws$retention_1_gate_30
draws$diff_day_7 <- draws$retention_7_gate_40 - draws$retention_7_gate_30

summarise_diff <- function(diffs, label) {
    ci <- quantile(diffs, c(0.025, 0.975))
    cat("\n", label, "\n", sep = "")
    cat("  Average difference (gate_40 minus gate_30):", round(mean(diffs), 2), "points\n")
    cat("  95% bootstrap interval:", round(ci[1], 2), "to", round(ci[2], 2), "points\n")
    cat("  Share of draws where gate_40 was lower:", round(100 * mean(diffs < 0), 1), "%\n")
}

cat("\n--- Bootstrap:", n_draws, "draws ---\n")
summarise_diff(draws$diff_day_1, "Day-1 retention")
summarise_diff(draws$diff_day_7, "Day-7 retention")

dir.create("output", showWarnings = FALSE)
write.csv(draws, file.path("output", "bootstrap_draws.csv"), row.names = FALSE)
cat("\nSaved:", file.path("output", "bootstrap_draws.csv"), "\n")
