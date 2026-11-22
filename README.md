# Cookie Cats A/B test: does moving the first gate change player retention?

**Business question:** the first gate in the mobile game Cookie Cats was moved from level 30 to level 40 for a random half of new players. Did that change how many players came back 1 and 7 days after installing, and should the game keep the gate at 30 or move it to 40?

**Data:** [Mobile Games A/B Testing - Cookie Cats](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) on Kaggle: 90,189 players, one row each.

**Tools:** R 4.4.2, RStudio, Tableau Public

**Status:** In progress

## Data quality log

| Check | Result | Decision |
|---|---|---|
| Missing values | None in any column | No action |
| Duplicate players | None | No action |
| Retention stored as text ("True"/"False") | Converted to TRUE/FALSE in memory | Raw file left unchanged |
| Sample balance | 44,700 v 45,489 (49.56% v 50.44%), chi-squared p = 0.009 | Below the strict SRM alarm level of 0.001; test treated as valid |
| Extreme player | One player (gate_30) with 49,854 rounds; next highest 2,961 | Flagged, not deleted; retention results identical to two decimals with and without |
