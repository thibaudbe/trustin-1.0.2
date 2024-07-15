# frozen_string_literal: true

require_relative "../trustin"
require_relative "evaluator_vat"
require_relative "helpers"

RSpec.describe EvaluatorVat do
  include EvaluatorVat
  include Helpers

  describe "#process_vat_evaluation" do
    let(:evaluation) {
      Evaluation.new(
        type: "VAT",
        value: "IE6388047V",
        score: score,
        state: state,
        reason: reason
      )
    }

    before { process_vat_evaluation(evaluation) }

    context "WHEN <score> is greater or equal to 50 AND <state> is 'unconfirmed' AND <reason> is 'unable_to_reach_api'" do
      let(:score) { 79 }
      let(:state) { "unconfirmed" }
      let(:reason) { "unable_to_reach_api" }

      it "should decrease <score> by 1" do
        expect(evaluation.score).to eq(78)
      end
    end

    context "WHEN <state> is 'unconfirmed' AND <reason> is 'unable_to_reach_api'" do
      let(:score) { 37 }
      let(:state) { "unconfirmed" }
      let(:reason) { "unable_to_reach_api" }

      it "should decrease <score> by 3" do
        expect(evaluation.score).to eq(34)
      end
    end

    context "WHEN <state> is 'favorable'" do
      let(:score) { 28 }
      let(:state) { "favorable" }
      let(:reason) { "company_opened" }

      it "should decrease <score> by 1" do
        expect(evaluation.score).to eq(27)
      end
    end

    context "WHEN <state> is 'unfavorable'" do
      let(:score) { 52 }
      let(:state) { "unfavorable" }
      let(:reason) { "company_closed" }

      it "should not decrease <score>" do
        expect(evaluation.score).to eq(52)
      end
    end

    context "WHEN <score> is equal to 0 AND <reason> is 'ongoing_database_update'" do
      let(:score) { 0 }
      let(:state) { "unconfirmed" }
      let(:reason) { "ongoing_database_update" }

      it "should reset <score> to 100" do
        expect(evaluation.score).to eq(100)
      end
    end
  end
end
