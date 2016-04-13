# encoding: utf-8
require 'test/filter_test_helpers'

describe "ContainerMetric events" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/Container_metric.conf")}
      }
    CONFIG
  end
  when_parsing_log(
    "syslog_program" => "doppler",
    "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
    "@message" => '{"cf_app_id":"6a4fa603-d03d-4d5d-9efc-73c4e815e053","cf_app_name":"notifications-ui","cf_org_id":"b152d3f9-ea0a-487a-b00c-688185a6ebcd","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"0f7c1e0e-e9b5-4afe-a095-71a058afcb1f","cf_space_name":"notifications-with-ui","cpu_percentage":0.019206287207808037,"disk_bytes":17309696,"event_type":"ContainerMetric","instance_index":0,"level":"info","memory_bytes":11165696,"msg":"","origin":"rep","time":"2016-04-12T10:18:19Z"}'
  ) do

    it "adds the ContainerMetric tag" do
      expect(subject["tags"]).to include "ContainerMetric"
    end

    it "sets @timestamp" do
      expect(subject["@timestamp"]).to eq Time.iso8601("2016-04-12T10:18:19Z")
    end

    it "sets @level to the loglevel" do
      expect(subject["@level"]).to eq "INFO"
    end

    it "sets @type to the type" do
      expect(subject["@type"]).to eq "ContainerMetric"
    end

		it "should set cf.app_id" do
		  expect(subject["cf"]["app_id"]).to eq "6a4fa603-d03d-4d5d-9efc-73c4e815e053"
		end

		it "should set cf.app_name" do
			expect(subject["cf"]["app_name"]).to eq "notifications-ui"
		end

		it "should set cf.org_id" do
			expect(subject["cf"]["org_id"]).to eq "b152d3f9-ea0a-487a-b00c-688185a6ebcd"
		end

		it "should set cf.org_name" do
			expect(subject["cf"]["org_name"]).to eq "system"
		end

		it "should set cf.space_id" do
			expect(subject["cf"]["space_id"]).to eq "0f7c1e0e-e9b5-4afe-a095-71a058afcb1f"
		end

		it "should set cf.space_name" do
			expect(subject["cf"]["space_name"]).to eq "notifications-with-ui"
		end

    it "sets ContainerMetric.name" do
      expect(subject["ContainerMetric"]["memory_bytes"]).to eq 11165696
    end

    it "sets ContainerMetric.disk_bytes" do
      expect(subject["ContainerMetric"]["disk_bytes"]).to eq 17309696
    end

    it "sets ContainerMetric.cpu_percentage" do
      expect(subject["ContainerMetric"]["cpu_percentage"]).to eq 0.019206287207808037
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
  end
end
