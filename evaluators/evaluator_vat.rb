# frozen_string_literal: true

require_relative 'helpers'

module EvaluatorVat
  include Helpers

  def process_vat_evaluation(evaluation)
    if should_fetch_company_state?(evaluation)
      fake_vat_api(evaluation)
    else
      update_vat_score(evaluation)
    end
    ensure_non_negative_score(evaluation)
  end

  def update_vat_score(evaluation)
    case evaluation.state
    when "unconfirmed"
      if evaluation.reason == "unable_to_reach_api"
        adjustment = evaluation.score >= 50 ? 1 : 3
        evaluation.score -= adjustment
      elsif evaluation.reason == "ongoing_database_update"
        evaluation.score = 100 if evaluation.score == 0
      end
    when "favorable"
      evaluation.score -= 1
    when "unfavorable"
      # Score does not decrease for unfavorable state
    end
  end

  def fake_vat_api(evaluation)
    data = [
      { state: "favorable", reason: "company_opened" },
      { state: "unfavorable", reason: "company_closed" },
      { state: "unconfirmed", reason: "unable_to_reach_api" },
      { state: "unconfirmed", reason: "ongoing_database_update" }
    ].sample

    evaluation.state = data[:state]
    evaluation.reason = data[:reason]
    evaluation.score = 100
  end
end