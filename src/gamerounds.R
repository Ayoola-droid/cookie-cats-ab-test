# gamerounds.R
# Did moving the gate change how much people played in their first 14 days?
# Game rounds are very skewed, so this compares medians and uses a
# rank-based test, and shows what the flagged player does to the averages.
# Run in RStudio with the Source button, or:  Rscript src\gamerounds.R

source(file.path("src", "load_data.R"))
players <- load_players()
without_flagged <- players[!players$extreme_rounds, ]

describe_rounds <- function(data, sample_name) {
    out <- aggregate(
        sum_gamerounds ~ version,
        data = data,
        FUN = function(x) c(
            players = length(x),
            median  = median(x),
            mean    = round(mean(x), 1),
            p90     = unname(quantile(x, 0.9)),
            max     = max(x)
        )
    )
    out <- cbind(sample = sample_name, version = out$version, as.data.frame(out$sum_gamerounds))
    out
}

cat("\n--- 1. Game rounds by group ---\n")
summary_table <- rbind(
    describe_rounds(players, "all players"),
    describe_rounds(without_flagged, "without flagged player")
)
print(summary_table, row.names = FALSE)

cat("\n--- 2. Mann-Whitney test (compares the whole spread, not the mean) ---\n")
mw <- wilcox.test(sum_gamerounds ~ version, data = players)
cat("All players: p-value =", signif(mw$p.value, 3), "\n")
mw_clean <- wilcox.test(sum_gamerounds ~ version, data = without_flagged)
cat("Without flagged player: p-value =", signif(mw_clean$p.value, 3), "\n")

cat("\n--- 3. How many players got near each gate? ---\n")
cat("(Rounds include replays, so this is an upper estimate of levels reached.)\n")
reach <- data.frame(
    version         = c("gate_30", "gate_40"),
    played_30_plus  = round(100 * tapply(players$sum_gamerounds >= 30, players$version, mean), 1),
    played_40_plus  = round(100 * tapply(players$sum_gamerounds >= 40, players$version, mean), 1),
    never_played    = round(100 * tapply(players$sum_gamerounds == 0, players$version, mean), 1)
)
print(reach, row.names = FALSE)

dir.create("output", showWarnings = FALSE)
write.csv(summary_table, file.path("output", "gamerounds_summary.csv"), row.names = FALSE)
cat("\nSaved:", file.path("output", "gamerounds_summary.csv"), "\n")
