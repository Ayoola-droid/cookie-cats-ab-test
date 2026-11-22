# Cookie Cats A/B test: does moving the first gate change player retention?

**Business question:** the first gate in the mobile game Cookie Cats was moved from level 30 to level 40 for a random half of new players. Did that change how many players came back 1 and 7 days after installing, and should the game keep the gate at 30 or move it to 40?

**Data:** [Mobile Games A/B Testing - Cookie Cats](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) on Kaggle: 90,189 players, one row each, with their test group, game rounds played in the first 14 days, and whether they came back after 1 and 7 days.

**Tools:** R 4.4.2 (base R only), RStudio, Tableau Public, Git

**Status:** In progress. Statistical analysis complete; Tableau story to follow.

## Key findings

1. **Moving the gate to level 40 cut 7-day retention by 0.82 points.** 19.02% of gate-30 players were still playing after a week, against 18.20% for gate 40: 4.3% fewer players (95% confidence interval −1.33 to −0.31 points, p = 0.0016). That is about 820 fewer active players for every 100,000 installs.
2. **A second method agrees.** In 2,000 bootstrap resamples, gate 40 had lower 7-day retention every time, and the bootstrap interval (−1.33 to −0.29 points) matches the formula.
3. **Day-1 retention fell slightly, but the gap could be chance.** 44.82% against 44.23%, a 0.59-point fall (interval −1.24 to +0.06, p = 0.074).
4. **Players did not play more with the later gate.** The median was 17 rounds for gate 30 and 16 for gate 40 (Mann-Whitney p = 0.05). Average rounds were identical at 51.3 once one probable bot with 49,854 rounds was set aside.
5. **The gate can only affect about a third of players.** Roughly 37% played 30 or more rounds; the other 63% stopped before reaching either gate.

**Recommendation:** keep the first gate at level 30. Moving it lost about 4 in every 100 of the players who would otherwise still be playing after a week and gained nothing in how much people played.

### Further detail

| Measure | Gate 30 | Gate 40 | Difference (40 minus 30) | Verdict |
|---|---|---|---|---|
| Players | 44,700 | 45,489 | | Split checked (see data-quality log) |
| 7-day retention | 19.02% | 18.20% | −0.82 points (−4.3%) | Worse at 40 |
| 1-day retention | 44.82% | 44.23% | −0.59 points (−1.3%) | Not proven |
| Median game rounds | 17 | 16 | −1 round | No clear difference |
| Mean game rounds, flagged player set aside | 51.3 | 51.3 | 0 | No difference |

**Limits:** the data has no purchases, so the cost of the drop cannot be put in euros. "Rounds played" includes replays, so the share of players reaching each gate is an upper estimate. Three tests were run; the 7-day result still passes a stricter cut-off for several tests (0.017), while the other two do not.

## Skills demonstrated

- **Experiment design checks:** sample ratio mismatch test on the group split before trusting any result
- **Hypothesis testing:** two-proportion z-tests with 95% confidence intervals, effect size in points and as relative change
- **Resampling:** a 2,000-draw stratified bootstrap as an assumption-light second check
- **Non-parametric statistics:** medians, percentiles and a Mann-Whitney test for heavily skewed data
- **Data quality:** reconciling cleaned counts to the raw file, flagging rather than deleting an outlier, and testing whether it changes the decision
- **R:** reusable loader function, input checks that stop on bad data, reproducible random draws with `set.seed`
- **Communication:** findings written for a non-technical decision-maker, with limits stated
- **Git:** Conventional Commits, one logical change per commit

## The Tableau story

To follow.

## Method

1. **Load and check** (`load_data.R`): confirm the expected columns, convert retention from "True"/"False" text to TRUE/FALSE, confirm only two groups exist, and flag players with more than 10,000 rounds. The raw file is never changed.
2. **Check the split** (`balance.R`): reconcile counts to the raw file and run a chi-squared test of the 50/50 split.
3. **Test retention** (`retention_test.R`): two-proportion tests on 1-day and 7-day retention, with and without the flagged player.
4. **Bootstrap** (`bootstrap.R`): resample each group's players 2,000 times (seed 2026) and take the middle 95% of the differences.
5. **Game rounds** (`gamerounds.R`): medians, means, 90th percentile and a Mann-Whitney test, with and without the flagged player, plus the share of players reaching 30 and 40 rounds.

## Data quality log

| Check | Result | Decision |
|---|---|---|
| Missing values | None in any column | No action |
| Duplicate players | None | No action |
| Retention stored as text ("True"/"False") | Converted to TRUE/FALSE in memory | Raw file left unchanged |
| Sample balance | 44,700 v 45,489 (49.56% v 50.44%), chi-squared p = 0.009 | Below the strict SRM alarm level of 0.001; test treated as valid |
| Extreme player | One player (gate_30) with 49,854 rounds; next highest 2,961 | Flagged, not deleted; retention results identical to two decimals with and without |
| Effect of the flagged player on game rounds | Raises the gate-30 mean from 51.3 to 52.5 | Report medians; show means both ways |

## How to rerun

Open `cookie-cats-ab-test.Rproj` in RStudio, then run each script with **Source**, in this order:

```
src/balance.R
src/retention_test.R
src/bootstrap.R
src/gamerounds.R
```

Each script loads the data itself, so any one can be run on its own. Results print to the Console, and the tables used by Tableau are written to `output/`.

## Setup

1. Clone the repo:
   ```
   git clone https://github.com/Ayoola-droid/cookie-cats-ab-test.git
   ```
2. Download `cookie_cats.csv` from the [Kaggle page](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) and put it in `data/raw/`. The raw file is not committed.
3. Install [R](https://cran.r-project.org/) (built with 4.4.2) and RStudio. No extra packages are needed: everything uses base R and the built-in `stats` package.
4. Open `cookie-cats-ab-test.Rproj`, so scripts run from the project folder.

## Scripts

| Script | Purpose |
|---|---|
| `src/load_data.R` | Loads, checks and cleans the raw file in memory; used by every other script |
| `src/inspect_raw.R` | First look at the raw file: shape, types, blanks, duplicates |
| `src/balance.R` | Reconciles to the raw file and tests the 50/50 split |
| `src/retention_test.R` | Two-proportion tests on 1-day and 7-day retention; writes `output/retention_results.csv` |
| `src/bootstrap.R` | 2,000-draw bootstrap of the retention differences; writes `output/bootstrap_draws.csv` |
| `src/gamerounds.R` | Game rounds by group and Mann-Whitney test; writes `output/gamerounds_summary.csv` |

## Project structure

```
data/
  raw/                      Kaggle file as downloaded (not committed)
src/                        R scripts
docs/                       README images
output/                     generated tables for Tableau (not committed)
cookie-cats-ab-test.Rproj   RStudio project file
README.md
.gitignore
```
