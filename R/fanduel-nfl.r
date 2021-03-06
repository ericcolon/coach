#' @rdname model_generic
#' @export
model_fd_nfl <- function(data, existing_rosters = list()) {

  # params
  total_salary <- 60E3
  roster_size <- 9L
  max_from_team = 4L

  # build model
  model_generic(data, total_salary, roster_size, max_from_team, existing_rosters) %>%
    add_fduel_nfl_roster_positions_constraint(data)
}

#' @importFrom ompr add_constraint sum_expr colwise
#' @keywords internal
add_fduel_nfl_roster_positions_constraint <- function(model, nfl) {
  # check position names
  assert_has_positions(nfl, c("QB", "RB", "WR", "TE", "D"))

  # position constraint helpers
  n <- nrow(nfl)
  is_position <- function(pos) {
    function(i) {
      as.integer(pos == nfl$position[i]) # function needs to be vectorized
    }
  }

  QB <- is_position("QB")
  RB <- is_position("RB")
  WR <- is_position("WR")
  TE <- is_position("TE")
  DST <- is_position("D")

  model %>%
    # quater back
    add_constraint(sum_expr(colwise(QB(i)) * x[i], i = 1:n) == 1) %>%

    # running back
    add_constraint(sum_expr(colwise(RB(i)) * x[i], i = 1:n) >= 2) %>%
    add_constraint(sum_expr(colwise(RB(i)) * x[i], i = 1:n) <= 3) %>%

    # wide receiver
    add_constraint(sum_expr(colwise(WR(i)) * x[i], i = 1:n) >= 3) %>%
    add_constraint(sum_expr(colwise(WR(i)) * x[i], i = 1:n) <= 4) %>%

    # tight end
    add_constraint(sum_expr(colwise(TE(i)) * x[i], i = 1:n) >= 1) %>%
    add_constraint(sum_expr(colwise(TE(i)) * x[i], i = 1:n) <= 2) %>%

    # defense
    add_constraint(sum_expr(colwise(DST(i)) * x[i], i = 1:n) == 1)
}
