# frozen_string_literal: true

module Helpers
  # Prevent useless request
  def should_fetch_company_state?(evaluation)
    evaluation.score > 0 \
      && evaluation.state == "unconfirmed" \
      && evaluation.reason == "ongoing_database_update" \
      || evaluation.score == 0
  end

  # Ensure score to be below zero
  def ensure_non_negative_score(evaluation)
    evaluation.score = 0 if evaluation.score < 0
  end
end
