# frozen_string_literal: true

require_relative 'helpers'

module EvaluatorSiren
  include Helpers

  def process_siren_evaluation(evaluation)
    if should_fetch_company_state?(evaluation)
      update_evaluation_from_siren_api(evaluation)
    else
      update_siren_score(evaluation)
    end
    ensure_non_negative_score(evaluation)
  end

  def update_evaluation_from_siren_api(evaluation)
    company_state = fetch_company_state(evaluation.value)
    if company_state == "Actif"
      evaluation.state = "favorable"
      evaluation.reason = "company_opened"
    else
      evaluation.state = "unfavorable"
      evaluation.reason = "company_closed"
    end
    evaluation.score = 100
  end

  def update_siren_score(evaluation)
    case evaluation.state
    when "unconfirmed"
      if evaluation.reason == "unable_to_reach_api"
        adjustment = evaluation.score >= 50 ? 5 : 1
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

  # Fetch a company state from SIREN API
  def fetch_company_state(company_id)
    uri = URI("https://public.opendatasoft.com/api/records/1.0/search/?dataset=economicref-france-sirene-v3" \
              "&q=#{company_id}&sort=datederniertraitementetablissement" \
              "&refine.etablissementsiege=oui")
    response = Net::HTTP.get(uri)
    parsed_response = JSON.parse(response)
    parsed_response["records"].first["fields"]["etatadministratifetablissement"]
  rescue StandardError => e
    "unknown"
  end
end
