# frozen_string_literal: true

require_relative "evaluators/helpers_spec"
require_relative "evaluators/evaluator_vat"
require_relative "evaluators/evaluator_siren"

RSpec.describe TrustIn do
  let(:siren_evaluation) { Evaluation.new(type: "SIREN", value: "123456789", score: 50, state: "unconfirmed", reason: "unable_to_reach_api") }
  let(:vat_evaluation) { Evaluation.new(type: "VAT", value: "IE6388047V", score: 50, state: "unconfirmed", reason: "unable_to_reach_api") }
  let(:unknown_evaluation) { Evaluation.new(type: "UNKNOWN", value: "000000000", score: 50, state: "unconfirmed", reason: "unable_to_reach_api") }
  let(:evaluations) { [siren_evaluation, vat_evaluation] }

  subject { described_class.new(evaluations) }

  describe "#initialize" do
    it "initializes with evaluations" do
      expect(subject.instance_variable_get(:@evaluations)).to eq(evaluations)
    end
  end

  describe "#update_scores" do
    before do
      allow(subject).to receive(:process_siren_evaluation)
      allow(subject).to receive(:process_vat_evaluation)
      subject.update_scores
    end

    it "updates scores for all evaluations" do
      expect(subject).to have_received(:process_siren_evaluation).with(siren_evaluation)
      expect(subject).to have_received(:process_vat_evaluation).with(vat_evaluation)
    end
  end

  describe "#update_score" do
    context "WHEN <evaluation> type is 'SIREN'" do
      before do
        siren_output = File.read('siren-example-output.json')
        parsed_siren_output = JSON.parse(siren_output)
        allow(EvaluatorSiren).to receive(:fetch_company_state).and_return(parsed_siren_output["records"].first["fields"]["etatadministratifetablissement"])
      end

      it "calls process_siren_evaluation" do
        expect(subject).to receive(:process_siren_evaluation).with(siren_evaluation)
        subject.update_score(siren_evaluation)
      end
    end

    context "WHEN <evaluation> type is 'VAT'" do
      it "calls process_vat_evaluation" do
        expect(subject).to receive(:process_vat_evaluation).with(vat_evaluation)
        subject.update_score(vat_evaluation)
      end
    end

    context "WHEN <evaluation> type is 'unknown'" do
      it "raises an error" do
        expect { subject.update_score(unknown_evaluation) }.to raise_error("Unknown evaluation type: UNKNOWN")
      end
    end
  end
end