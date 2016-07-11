# encoding: utf-8
require 'test/filter_test_helpers'

describe "ValueMetric events" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/value_metric.conf")}
      }
    CONFIG
  end
  when_parsing_log(
    "syslog_program" => "doppler",
    "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
    "@message" => '{"cf_origin":"firehose","deployment":"cf","event_type":"ValueMetric","index":"0","ip":"10.0.16.18","job":"diego_brain-partition-6531e9947fabe4e829e5","level":"info","msg":"","name":"logSenderTotalMessagesRead","origin":"p-rabbitmq","time":"2016-04-12T09:50:54Z","unit":"count","value":123}'
  ) do

    it "adds the ValueMetric tag" do
      expect(subject["tags"]).to include "ValueMetric"
    end

    it "sets @timestamp" do
      expect(subject["@timestamp"]).to eq Time.iso8601("2016-04-12T09:50:54Z")
    end

    it "sets @level to the loglevel" do
      expect(subject["@level"]).to eq "INFO"
    end

    it "sets @type to the type" do
      expect(subject["@type"]).to eq "ValueMetric"
    end

    it "sets ValueMetric.origin" do
      expect(subject["ValueMetric"]["origin"]).to eq "p-rabbitmq"
    end

    it "sets ValueMetric.name" do
      expect(subject["ValueMetric"]["name"]).to eq "logSenderTotalMessagesRead"
    end

    it "sets ValueMetric.value" do
      expect(subject["ValueMetric"]["value"]).to eq 123
    end

    it "sets ValueMetric.unit" do
      expect(subject["ValueMetric"]["unit"]).to eq "count"
    end

    it "drops ValueMetric.msg" do
      expect(subject["ValueMetric"]["msg"]).to eq nil
    end

    it "drops ValueMetric.event_type" do
      expect(subject["ValueMetric"]["event_type"]).to eq nil
    end

    it "drops drop ValueMetric.level" do
      expect(subject["ValueMetric"]["level"]).to eq nil
    end

    it "drops ValueMetric.cf_origin" do
      expect(subject["ValueMetric"]["cf_origin"]).to eq nil
    end

    it "sets @source.deploymen" do
      expect(subject["@source"]["deployment"]).to eq "cf"
    end

    it "sets @source.job" do
      expect(subject["@source"]["job"]).to eq "diego_brain-partition-6531e9947fabe4e829e5"
    end

    it "sets @source.index" do
      expect(subject["@source"]["index"]).to eq "0"
    end

    it "sets @source.ip" do
      expect(subject["@source"]["ip"]).to eq "10.0.16.18"
    end
  end
end
