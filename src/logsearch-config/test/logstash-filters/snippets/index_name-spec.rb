# encoding: utf-8
require 'test/filter_test_helpers'

describe "index naming" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/index_name.conf")}
      }
    CONFIG
  end

  context "when parsing UAA logs" do
    when_parsing_log(
      "@source" => { "program" => "uaa" }
    ) do

      it "sets metadata.index to uaa" do
        expect(subject["@metadata"]["index"]).to eq "uaa"
      end
    end
  end

  context "when parsing nats logs" do
    when_parsing_log(
      "@source" => { "program" => "nats" }
    ) do

      it "sets metadata.index to nats" do
        expect(subject["@metadata"]["index"]).to eq "nats"
      end
    end
  end

  context "when parsing bbs logs" do
    when_parsing_log(
      "@source" => { "program" => "bbs" }
    ) do

      it "sets metadata.index to bbs" do
        expect(subject["@metadata"]["index"]).to eq "bbs"
      end
    end
  end

  context "when parsing rep logs" do
    when_parsing_log(
      "@source" => { "program" => "rep" }
    ) do

      it "sets metadata.index to rep" do
        expect(subject["@metadata"]["index"]).to eq "rep"
      end
    end
  end

  context "when parsing cloud controller logs" do
    when_parsing_log(
      "@source" => { "program" => "cloud_controller_ng" }
    ) do

      it "sets metadata.index to cc_ng" do
        expect(subject["@metadata"]["index"]).to eq "cc_ng"
      end
    end
  end

  context "when parsing LogMessage logs" do
    when_parsing_log(
      "@type" => "LogMessage"
    ) do

      it "sets metadata.index to uaa" do
        expect(subject["@metadata"]["index"]).to eq "log_message"
      end
    end
  end

  context "when parsing CounterEvent logs" do
    when_parsing_log(
      "@type" => "CounterEvent"
    ) do

      it "sets metadata.index to counter_event" do
        expect(subject["@metadata"]["index"]).to eq "counter_event"
      end
    end
  end

  context "when parsing ContainerMetric logs" do
    when_parsing_log(
      "@type" => "ContainerMetric"
    ) do

      it "sets metadata.index to container_metric" do
        expect(subject["@metadata"]["index"]).to eq "container_metric"
      end
    end
  end

  context "when parsing ValueMetric logs" do
    when_parsing_log(
      "@type" => "ValueMetric"
    ) do

      it "sets metadata.index to value_metric" do
        expect(subject["@metadata"]["index"]).to eq "value_metric"
      end
    end
  end

  context "when parsing firehose Error logs" do
    when_parsing_log(
      "@type" => "Error"
    ) do

      it "sets metadata.index to error" do
        expect(subject["@metadata"]["index"]).to eq "error"
      end
    end
  end

  context "when parsing HttpStartStop logs" do
    when_parsing_log(
      "@type" => "HttpStartStop"
    ) do

      it "sets metadata.index to http_start_stop" do
        expect(subject["@metadata"]["index"]).to eq "http_start_stop"
      end
    end
  end

  context "when parsing other logs" do
    when_parsing_log(
      "@source" => { "program" => "staget" }
    ) do

      it "sets metadata.index to http_start_stop" do
        expect(subject["@metadata"]["index"]).to eq "default"
      end
    end
  end
end

