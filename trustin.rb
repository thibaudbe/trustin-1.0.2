# frozen_string_literal: true

require "json"
require "net/http"
require_relative "evaluators/evaluator_vat"
require_relative "evaluators/evaluator_siren"

class TrustIn
  include EvaluatorVat
  include EvaluatorSiren

  def initialize(evaluations)
    @evaluations = evaluations
  end

  def update_scores
    @evaluations.each do |evaluation|
      update_score(evaluation)
    end
  end

  def update_score(evaluation)
    case evaluation.type
    when "SIREN"
      process_siren_evaluation(evaluation)
    when "VAT"
      process_vat_evaluation(evaluation)
    else
      raise "Unknown evaluation type: #{evaluation.type}"
    end
  end
end

class Evaluation
  attr_accessor :type, :value, :score, :state, :reason

  def initialize(type:, value:, score:, state:, reason:)
    @type = type
    @value = value
    @score = score
    @state = state
    @reason = reason
  end

  def to_s()
    "#{@type}, #{@value}, #{@score}, #{@state}, #{@reason}"
  end
end
