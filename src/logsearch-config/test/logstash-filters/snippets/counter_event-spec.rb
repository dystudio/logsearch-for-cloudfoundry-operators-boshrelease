# encoding: utf-8
require 'test/filter_test_helpers'

describe "CounterEvent metric parsing" do

  before(:all) do
    # change path of the source.deployment translation table so it works in test
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/counter_event.conf")}
      }
    CONFIG
  end

  when_parsing_log(
    "@type" => "syslog",
    "syslog_program" => "doppler",
    "@message" => '{"cf_origin":"firehose","delta":10,"event_type":"CounterEvent","level":"info","msg":"","name":"dropsondeMarshaller.counterEventMarshalled","origin":"MetronAgent","time":"2016-04-12T10:16:37Z","total":3770256}'
  ) do

    it "adds the CounterEvent tag" do
      expect(subject["tags"]).to include "CounterEvent"
    end

    it "parses CounterEvent.name" do
      expect(subject["CounterEvent"]["name"]).to eq "dropsondeMarshaller.counterEventMarshalled"
    end

    it "parses CounterEvent.origin" do
      expect(subject["CounterEvent"]["origin"]).to eq "MetronAgent"
    end

    it "parses CounterEvent.delta" do
      expect(subject["CounterEvent"]["delta"]).to eq 10
    end

    it "parses CounterEvent.total" do
      expect(subject["CounterEvent"]["total"]).to eq 3770256
    end

    it "sets @level" do
      expect(subject["@level"]).to eq "INFO"
    end

    it "sets @timestamp" do
      expect(subject["@timestamp"]).to eq Time.parse("2016-04-12T10:16:37Z")
    end

    it "sets @source.program" do
      expect(subject["@source"]["program"]).to eq "doppler"
    end
  end
end
