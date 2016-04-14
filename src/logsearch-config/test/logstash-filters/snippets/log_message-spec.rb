# encoding: utf-8
require 'test/filter_test_helpers'

describe "LogMessage events" do
  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/log_message.conf")}
      }
    CONFIG
  end
  when_parsing_log(
    "syslog_program" => "doppler",
    "syslog_hostname" => "95c570e0-c2eb-4f43-b33e-69a456fe96f0",
    "@message" => '{"cf_app_id":"cfcb2d5a-244a-4c51-b22b-8562d13822a9","cf_app_name":"chatty-app","cf_org_id":"8b877d32-d147-4729-a8be-33df22f9221e","cf_org_name":"org_test","cf_origin":"firehose","cf_space_id":"d58e7bc0-72d0-45ef-9fdc-cdd168dee98b","cf_space_name":"space_test","event_type":"LogMessage","level":"info","message_type":"OUT","msg":"{\"data\":\"di7xex8gsfer85yykodbbi97qtaf3xrz\",\"time\":\"1460455471\"}","origin":"rep","source_instance":"3","source_type":"APP","time":"2016-04-12T10:04:31Z","timestamp":1460455471700095202}'
  ) do

    it "adds the LogMessage tag" do
      expect(subject["tags"]).to include "LogMessage"
    end

    it "sets @timestamp" do
      expect(subject["@timestamp"]).to eq Time.iso8601("2016-04-12T10:04:31Z")
    end

    it "sets @timestamp_ns" do
      expect(subject["@timestamp_ns"]).to eq 95202
    end

    it "sets @level to the loglevel" do
      expect(subject["@level"]).to eq "INFO"
    end

    it "sets @type to the type" do
      expect(subject["@type"]).to eq "LogMessage"
    end

    it "sets @source.program to the syslog_program" do
      expect(subject["@source"]["program"]).to eq "doppler"
    end

    it "sets @source.host to the syslog_hostname" do
      expect(subject["@source"]["host"]).to eq "95c570e0-c2eb-4f43-b33e-69a456fe96f0"
    end

    it "sets @source.host to the source_instance" do
      expect(subject["@source"]["index"]).to eq 3
    end

    it "sets @message to the msg" do
      expect(subject["@message"]).to eq "{\"data\":\"di7xex8gsfer85yykodbbi97qtaf3xrz\",\"time\":\"1460455471\"}"
    end

		it "should set cf.app_id" do
		  expect(subject["cf"]["app_id"]).to eq "cfcb2d5a-244a-4c51-b22b-8562d13822a9"
		end

		it "should set cf.app_name" do
			expect(subject["cf"]["app_name"]).to eq "chatty-app"
		end

		it "should set cf.org_id" do
			expect(subject["cf"]["org_id"]).to eq "8b877d32-d147-4729-a8be-33df22f9221e"
		end

		it "should set cf.org_name" do
			expect(subject["cf"]["org_name"]).to eq "org_test"
		end

		it "should set cf.space_id" do
			expect(subject["cf"]["space_id"]).to eq "d58e7bc0-72d0-45ef-9fdc-cdd168dee98b"
		end

		it "should set cf.space_name" do
			expect(subject["cf"]["space_name"]).to eq "space_test"
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
  end
end
