require "spec_helper"
require "elk"

describe Elk::SMS do
  before { configure_elk }
  let(:url) { "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS" }

  describe ".send" do
    let(:from)    { "+46761042247" }
    let(:to)      { "+46704508449" }
    let(:message) { "Your order #171 has now been sent!" }

    context "ordinary SMS" do
      before(:each) do
        stub_request(:post, url).
          with(body: { from: from, message: message, to: to }, headers: post_headers).
          to_return(fixture('sends_a_sms.txt'))
      end

      subject(:sms) { described_class.send(from: from, to: to, message: message) }

      it "should not create warnings" do
        expect { sms }.to_not output.to_stderr
      end

      describe "#from" do
        subject { sms.from }
        it { is_expected.to eq(from) }
      end

      describe "#to" do
        subject { sms.to }
        it { is_expected.to eq(to) }
      end

      describe "#message" do
        subject { sms.message }
        it { is_expected.to eq(message) }
      end

      describe "#direction" do
        subject { sms.direction }
        it { is_expected.to eq("outgoing") }
      end

      describe "#status" do
        subject { sms.status }
        it { is_expected.to eq("delivered") }
      end
    end

    context "flash SMS" do
      before(:each) do
        @stub = stub_request(:post, url).
          with(body: { from: from, message: message, to: to, flashsms: "yes" },
               headers: post_headers).
          to_return(fixture('sends_a_sms.txt'))
      end

      it "should send flash SMS through API" do
        described_class.send(from: from, to: to, message: message, flash: true)

        expect(@stub).to have_been_requested
      end
    end

    context 'multiple recipients' do
      before do
        stub_request(:post, url).
          with(body: { from: from, message: message, to: to.join(",") },
               headers: post_headers).
          to_return(fixture('sends_a_sms_to_multiple_recipients.txt'))
      end

      let(:to) { ["+46704508448", "+46704508449"] }

      subject(:messages) { described_class.send(from: from, to: to, message: message) }

      it "should create two messages" do
        expect(messages.size).to eq(2)
      end

      context "first sms" do
        subject(:sms) { messages[0] }

        it "should contain first message" do
          expect(sms.to).to eq(to[0])
          expect(sms.message_id).to eq("sb326c7a214f9f4abc90a11bd36d6abc3")
        end
      end

      context "second sms" do
        subject(:sms) { messages[1] }

        it "should contain second message" do
          expect(sms.to).to eq(to[1])
          expect(sms.message_id).to eq("s47a89d6cc51d8db395d45ae7e16e86b7")
        end
      end

      context "with recipients as array and comma separated string" do
        subject(:as_comma) { described_class.send(from: from, to: to.join(","), message: message) }
        subject(:as_array) { described_class.send(from: from, to: to, message: message) }

        it "response should send the same messages" do
          expect(as_comma.map(&:message_id)).to eq(as_array.map(&:message_id))
        end
      end
    end

    context "with too long sender" do
      before(:each) do
        stub_request(:post, url).
          with(body: { from: from, message: message, to: to }, headers: post_headers).
          to_return(fixture('sends_a_sms_with_long_sender.txt'))
      end

      subject(:sms) { described_class.send(from: from, to: to, message: message) }

      let(:from) { "VeryVeryVeryVeryLongSenderName" }

      it "should create warning" do
        expect { sms }.to output("SMS 'from' value #{from} will be capped at 11 chars\n").to_stderr
      end

      describe "#from" do
        subject { sms.from }
        it { is_expected.to eq(from) }
      end

      describe "#to" do
        subject { sms.to }
        it { is_expected.to eq(to) }
      end

      describe "#message" do
        subject { sms.message }
        it { is_expected.to eq(message) }
      end

      describe "#direction" do
        subject { sms.direction }
        it { is_expected.to eq("outgoing") }
      end

      describe "#status" do
        subject { sms.status }
        it { is_expected.to eq("delivered") }
      end
    end

    context "with invalid number" do
      before(:each) do
        stub_request(:post, url).
          with(body: {:from => "+46761042247", :message => "Your order #171 has now been sent!", :to => "monkey"},
               headers: post_headers).
          to_return(fixture('invalid_to_number.txt'))
      end

      it 'should handle invalid to number' do
        expect {
          described_class.send(:from => '+46761042247',
            :to => 'monkey',
            :message => 'Your order #171 has now been sent!')
        }.to raise_error(Elk::BadRequest, 'Invalid to number')
      end
    end

    context "without parameters" do
      it 'should handle no parameters' do
        expect {
          described_class.send({})
        }.to raise_error(Elk::MissingParameter)
      end
    end
  end

  describe ".all" do
    before(:each) do
      stub_request(:get, url).
        with(headers: get_headers).
        to_return(fixture('sms_history.txt'))
    end

    subject(:history) { described_class.all }

    it "should have return all messages" do
      expect(history.size).to eq(3)
    end

    context "first item" do
      subject(:sms) { history[0] }

      it "should contain the correct message" do
        expect(sms.message).to eq("Your order #171 has now been sent!")
      end
    end

    context "second item" do
      subject(:sms) { history[1] }

      it "should contain the correct message" do
        expect(sms.message).to eq("I'd like to order a pair of elks!")
      end
    end

    context "third item" do
      subject(:sms) { history[2] }

      it "should contain the correct message" do
        expect(sms.message).to eq("Want an elk?")
      end
    end
  end

  describe "#reload" do
    before(:each) do
      stub_request(:get, url).
        with(headers: get_headers).
        to_return(fixture('sms_history.txt'))

      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS/s8952031bb83bf3e64f8e13b071c131c0").
        with(headers: get_headers).
        to_return(fixture('reloads_a_sms.txt'))
    end

    subject(:sms) { described_class.all.first }

    it "should return true" do
      expect(sms.reload).to be(true)
    end

    it "should not change object_id" do
      expect { sms.reload }.to_not change { sms.object_id }
    end

    it "should update loaded_at" do
      expect { sms.reload }.to change { sms.loaded_at }
    end
  end
end
