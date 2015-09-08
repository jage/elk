require "spec_helper"
require "elk"

describe Elk::Util do
  describe "#verify_parameters" do
    let(:parameters) { { from: "mom", to: "god" } }

    context "with all required parameters" do
      let(:required_parameters) { [:from, :to] }

      it "should not raise any exceptions" do
        extend Elk::Util
        expect {
          verify_parameters(parameters, required_parameters)
        }.to_not raise_error
      end
    end

    context "with a missing required parameter" do
      let(:required_parameters) { [:from, :to, :message] }

      it "should raise missing parameter exception" do
        extend Elk::Util
        expect {
          verify_parameters(parameters, required_parameters)
        }.to raise_error(Elk::MissingParameter)
      end
    end
  end

  describe ".parse_json" do
    subject { Elk::Util }

    context "with empty object body" do
      let(:body) { "{}" }

      it "should return empty hash" do
        expect(subject.parse_json(body)).to eq({})
      end
    end

    context "with garbage json" do
      let(:body) { fixture("bad_response_body.txt").read }

      it "should raise bad response exception" do
        expect { subject.parse_json(body) }.to raise_error(Elk::BadResponse)
      end
    end
  end
end
