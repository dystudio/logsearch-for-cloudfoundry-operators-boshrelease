# encoding: utf-8
require 'test/filter_test_helpers'

describe "firehose" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/firehose.conf")}
      }
    CONFIG
  end

  shared_examples "a firehose log" do |original_message|
    let(:log_data) { JSON.parse(original_message) }

    it "adds the firehose tag" do
      expect(subject["tags"]).to include "firehose"
    end

    it "parses the message as JSON under the key event_type" do
      expect(subject[log_data["event_type"]]).to be_a Hash
    end

    it "sets @source.deploymen" do
      expect(subject["@source"]["deployment"]).to eq log_data["deployment"]
    end

    it "sets @source.job" do
      expect(subject["@source"]["job"]).to eq log_data["job"]
    end


    it "sets @source.ip" do
      expect(subject["@source"]["ip"]).to eq log_data["ip"]
    end

    it "sets @type to the event_type" do
      expect(subject["@type"]).to eq log_data["event_type"]
    end
  end

  describe "parsing ValueMetric logs" do
    original_message = '{"cf_origin":"firehose","deployment":"cf","event_type":"ValueMetric","index":"0","ip":"10.0.16.18","job":"diego_brain-partition-6531e9947fabe4e829e5","level":"info","msg":"","name":"logSenderTotalMessagesRead","origin":"p-rabbitmq","time":"2016-04-12T09:50:54Z","unit":"count","value":123}'
    when_parsing_log(
      "syslog_program" => "doppler",
      "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
      "@message" => original_message
    ) do

      it_behaves_like "a firehose log", original_message

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.iso8601("2016-04-12T09:50:54Z")
      end

      it "sets @level to the loglevel" do
        expect(subject["@level"]).to eq "INFO"
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

      it "sets @source.index to index" do
        expect(subject["@source"]["index"]).to eq "0"
      end
    end
  end

  describe "parsing ContainerMetric logs" do
    original_message = '{"cf_app_id":"574069a6-bc4f-4d2b-9ad1-a0f7c7f494d6","cf_app_name":"apps-manager-js","cf_org_id":"ce88b618-b2b6-4526-ad87-b643c2323d37","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"5936d220-f4dc-4ae4-9f38-f00042e5b2a2","cf_space_name":"system","cpu_percentage":0.02464272940939592,"deployment":"cf","disk_bytes":9920512,"event_type":"ContainerMetric","index":"0","instance_index":4,"ip":"10.0.16.19","job":"diego_cell-partition-6531e9947fabe4e829e5","level":"info","memory_bytes":7208960,"msg":"","origin":"rep","time":"2016-07-12T11:37:56Z"}'
    when_parsing_log(
      "syslog_program" => "doppler",
      "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
      "@message" => original_message
    ) do

      it_behaves_like "a firehose log", original_message

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.iso8601("2016-07-12T11:37:56Z")
      end

      it "sets @level to the loglevel" do
        expect(subject["@level"]).to eq "INFO"
      end

      it "should set cf.app_id" do
        expect(subject["cf"]["app_id"]).to eq "574069a6-bc4f-4d2b-9ad1-a0f7c7f494d6"
      end

      it "should set cf.app_name" do
        expect(subject["cf"]["app_name"]).to eq "apps-manager-js"
      end

      it "should set cf.org_id" do
        expect(subject["cf"]["org_id"]).to eq "ce88b618-b2b6-4526-ad87-b643c2323d37"
      end

      it "should set cf.org_name" do
        expect(subject["cf"]["org_name"]).to eq "system"
      end

      it "should set cf.space_id" do
        expect(subject["cf"]["space_id"]).to eq "5936d220-f4dc-4ae4-9f38-f00042e5b2a2"
      end

      it "should set cf.space_name" do
        expect(subject["cf"]["space_name"]).to eq "system"
      end

      it "sets ContainerMetric.memory_bytes" do
        expect(subject["ContainerMetric"]["memory_bytes"]).to eq 7208960
      end

      it "sets ContainerMetric.disk_bytes" do
        expect(subject["ContainerMetric"]["disk_bytes"]).to eq 9920512
      end

      it "sets ContainerMetric.cpu_percentage" do
        expect(subject["ContainerMetric"]["cpu_percentage"]).to eq 0.02464272940939592
      end

      it "drops ContainerMetric.msg" do
        expect(subject["ContainerMetric"]["msg"]).to eq nil
      end

      it "drops ContainerMetric.event_type" do
        expect(subject["ContainerMetric"]["event_type"]).to eq nil
      end

      it "drops drop ContainerMetric.level" do
        expect(subject["ContainerMetric"]["level"]).to eq nil
      end

      it "drops ContainerMetric.origin" do
        expect(subject["ContainerMetric"]["origin"]).to eq nil
      end

      it "drops ContainerMetric.cf_origin" do
        expect(subject["ContainerMetric"]["cf_origin"]).to eq nil
      end

      it "sets @source.index to instance_index" do
        expect(subject["@source"]["index"]).to eq 4
      end
    end
  end

  describe "parsing LogMessage logs" do
    original_message = '{"cf_app_id":"d5427320-ee84-4320-8d67-69069716f4f8","cf_app_name":"cf-failure","cf_org_id":"ce88b618-b2b6-4526-ad87-b643c2323d37","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"5936d220-f4dc-4ae4-9f38-f00042e5b2a2","cf_space_name":"system","deployment":"cf","event_type":"LogMessage","index":"0","ip":"10.0.16.19","job":"diego_cell-partition-6531e9947fabe4e829e5","level":"info","message_type":"OUT","msg":"preparing to fail","origin":"rep","source_instance":"0","source_type":"APP","time":"2016-07-12T12:48:34Z","timestamp":1468327714280640174}'
    when_parsing_log(
      "syslog_program" => "doppler",
      "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
      "@message" => original_message
    ) do

      it_behaves_like "a firehose log", original_message

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.iso8601("2016-07-12T12:48:34.280Z")
      end

      it "sets @timestamp_ns" do
        expect(subject["@timestamp_ns"]).to eq 640174
      end

      it "sets @level to the loglevel" do
        expect(subject["@level"]).to eq "INFO"
      end

      it "sets @source.program to the syslog_program" do
        expect(subject["@source"]["program"]).to eq "doppler"
      end

      it "sets @source.host to the syslog_hostname" do
        expect(subject["@source"]["host"]).to eq "95c570e0-c2eb-4f43-b33e-69a456fe96f0"
      end

      it "sets @message to the msg" do
        expect(subject["@message"]).to eq "preparing to fail"
      end

      it "should set cf.app_id" do
        expect(subject["cf"]["app_id"]).to eq "d5427320-ee84-4320-8d67-69069716f4f8"
      end

      it "should set cf.app_name" do
        expect(subject["cf"]["app_name"]).to eq "cf-failure"
      end

      it "should set cf.org_id" do
        expect(subject["cf"]["org_id"]).to eq "ce88b618-b2b6-4526-ad87-b643c2323d37"
      end

      it "should set cf.org_name" do
        expect(subject["cf"]["org_name"]).to eq "system"
      end

      it "should set cf.space_id" do
        expect(subject["cf"]["space_id"]).to eq "5936d220-f4dc-4ae4-9f38-f00042e5b2a2"
      end

      it "should set cf.space_name" do
        expect(subject["cf"]["space_name"]).to eq "system"
      end

      it "sets LogMessage.name" do
        expect(subject["LogMessage"]["message_type"]).to eq "OUT"
      end

      it "sets LogMessage.disk_bytes" do
        expect(subject["LogMessage"]["source_type"]).to eq "APP"
      end

      it "drops LogMessage.msg" do
        expect(subject["LogMessage"]["msg"]).to eq nil
      end

      it "drops LogMessage.event_type" do
        expect(subject["LogMessage"]["event_type"]).to eq nil
      end

      it "drops drop LogMessage.level" do
        expect(subject["LogMessage"]["level"]).to eq nil
      end

      it "drops LogMessage.origin" do
        expect(subject["LogMessage"]["origin"]).to eq nil
      end

      it "adds the firehose tag" do
        expect(subject["tags"]).to include "firehose"
      end

      it "sets @source.index to source_instance" do
        expect(subject["@source"]["index"]).to eq "0"
      end
    end
  end

  describe "parsing CounterEvent logs" do
    original_message = '{"cf_origin":"firehose","delta":4371,"deployment":"cf","event_type":"CounterEvent","index":"2","ip":"10.0.16.79","job":"dedicated-node-partition-6531e9947fabe4e829e5","level":"info","msg":"","name":"dropsondeAgentListener.receivedByteCount","origin":"MetronAgent","time":"2016-07-12T13:34:53Z","total":78735348}'
    when_parsing_log(
      "@type" => "syslog",
      "syslog_program" => "doppler",
      "@message" => original_message
    ) do

      it_behaves_like "a firehose log", original_message

      it "parses CounterEvent.name" do
        expect(subject["CounterEvent"]["name"]).to eq "dropsondeAgentListener.receivedByteCount"
      end

      it "parses CounterEvent.origin" do
        expect(subject["CounterEvent"]["origin"]).to eq "MetronAgent"
      end

      it "parses CounterEvent.delta" do
        expect(subject["CounterEvent"]["delta"]).to eq 4371
      end

      it "parses CounterEvent.total" do
        expect(subject["CounterEvent"]["total"]).to eq 78735348
      end

      it "sets @level" do
        expect(subject["@level"]).to eq "INFO"
      end

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.iso8601("2016-07-12T13:34:53Z")
      end

      it "sets @source.program" do
        expect(subject["@source"]["program"]).to eq "doppler"
      end

      it "sets @source.index" do
        expect(subject["@source"]["index"]).to eq "2"
      end
    end
  end
end
