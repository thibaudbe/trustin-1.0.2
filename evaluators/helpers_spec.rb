# frozen_string_literal: true

require_relative "../trustin"
require_relative "helpers"

RSpec.describe Helpers do
  include Helpers

  describe "#should_fetch_company_state" do
    let(:evaluation) {
      Evaluation.new(
        type: "SIREN",
        value: "123456789",
        score: score,
        state: state,
        reason: reason
      )
    }

    subject { should_fetch_company_state?(evaluation) }

    context "WHEN <score> is greater than 0 AND <state> is 'unconfirmed' AND <reason> 'ongoing_database_update'" do
      let(:score) { 10 }
      let(:state) { "unconfirmed" }
      let(:reason) { "ongoing_database_update" }

      it "should return true" do
        expect(subject).to eq(true)
      end
    end

    context "WHEN <score> is greater than 0 AND <state> is not 'unconfirmed'" do
      let(:score) { 10 }
      let(:state) { "confirmed" }
      let(:reason) { "ongoing_database_update" }

      it "should return false" do
        expect(subject).to eq(false)
      end
    end

    context "WHEN <score> is greater than 0 AND <state> is 'unconfirmed' AND <reason> is not 'ongoing_database_update'" do
      let(:score) { 10 }
      let(:state) { "unconfirmed" }
      let(:reason) { "other_reason" }

      it "should return false" do
        expect(subject).to eq(false)
      end
    end

    context "WHEN <score> is 0" do
      let(:score) { 0 }
      let(:state) { "unconfirmed" }
      let(:reason) { "any_reason" }

      it "should return true" do
        expect(subject).to eq(true)
      end
    end

    context "WHEN <score> is less than 0" do
      let(:score) { -5 }
      let(:state) { "unconfirmed" }
      let(:reason) { "ongoing_database_update" }

      it "should return false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#ensure_non_negative_score" do
    let(:evaluation) {
      Evaluation.new(
        type: "SIREN",
        value: "123456789",
        score: score,
        state: "unconfirmed",
        reason: "unable_to_reach_api"
      )
    }

    before { ensure_non_negative_score(evaluation) }

    context "WHEN <score> is negative" do
      let(:score) { -5 }

      it "should set <score> to 0" do
        expect(evaluation.score).to eq(0)
      end
    end

    context "WHEN <score> is zero or positive" do
      let(:score) { 10 }

      it "should  not change <score>" do
        expect(evaluation.score).to eq(10)
      end
    end
  end
end
