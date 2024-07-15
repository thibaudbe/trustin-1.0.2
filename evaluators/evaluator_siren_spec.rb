# frozen_string_literal: true

require_relative "../trustin"
require_relative "evaluator_siren"
require_relative "helpers"

RSpec.describe EvaluatorSiren do
  include EvaluatorSiren
  include Helpers

  describe "#process_siren_evaluation" do
    let(:evaluation) {
      Evaluation.new(
        type: "SIREN",
        value: value,
        score: score,
        state: state,
        reason: reason
      )
    }

    before { process_siren_evaluation(evaluation) }

    context "WHEN <score> is greater or equal to 50 AND <state> is 'unconfirmed' and <reason> is 'unable_to_reach_api'" do
      let(:score) { 79 }
      let(:state) { "unconfirmed" }
      let(:reason) { "unable_to_reach_api" }
      let(:value) { "123456789" }

      it "should decreases the score by 5" do
        expect(evaluation.score).to eq(74)
      end
    end

    context "WHEN <state> is 'unconfirmed' AND <reason> is 'unable_to_reach_api'" do
      let(:score) { 37 }
      let(:state) { "unconfirmed" }
      let(:reason) { "unable_to_reach_api" }
      let(:value) { "123456789" }

      it "should decreases the score by 1" do
        expect(evaluation.score).to eq(36)
      end
    end

    context "WHEN <state> is 'favorable'" do
      let(:score) { 28 }
      let(:state) { "favorable" }
      let(:reason) { "company_opened" }
      let(:value) { "123456789" }

      it "should decreases the score by 1" do
        expect(evaluation.score).to eq(27)
      end
    end

    context "WHEN <state> is 'unconfirmed' AND <reason> is 'ongoing_database_update'" do
      let(:score) { 42 }
      let(:state) { "unconfirmed" }
      let(:reason) { "ongoing_database_update" }
      let(:value) { "832940670" }

      before do
        allow(EvaluatorSiren).to receive(:fetch_company_state).with(evaluation.value).and_return("Actif")
      end

      it "should assigns <state> AND <reason> to the evaluation based on the API response AND <score> is 100" do
        expect(evaluation.state).to eq("favorable")
        expect(evaluation.reason).to eq("company_opened")
        expect(evaluation.score).to eq(100)
      end
    end

    context "WHEN <score> is equal to 0" do
      let(:score) { 0 }
      let(:state) { "favorable" }
      let(:reason) { "company_opened" }
      let(:value) { "320878499" }

      before do
        allow(EvaluatorSiren).to receive(:fetch_company_state).with(evaluation.value).and_return("Inactif")
      end

      it "should assigns <state> and <reason> to the evaluation based on the API response and sets <score> to 100" do
        expect(evaluation.state).to eq("unfavorable")
        expect(evaluation.reason).to eq("company_closed")
        expect(evaluation.score).to eq(100)
      end
    end

    context "WHEN <state> is 'unfavorable'" do
      let(:score) { 52 }
      let(:state) { "unfavorable" }
      let(:reason) { "company_closed" }
      let(:value) { "123456789" }

      it "should not decrease its score" do
        expect(evaluation.score).to eq(52)
      end
    end

    context "WHEN <state> is 'unfavorable' AND <score> equal to 0" do
      let(:score) { 0 }
      let(:state) { "unfavorable" }
      let(:reason) { "company_closed" }
      let(:value) { "123456789" }

      it "should does not call the API" do
        expect(Net::HTTP).not_to receive(:get)
      end
    end
  end
end
