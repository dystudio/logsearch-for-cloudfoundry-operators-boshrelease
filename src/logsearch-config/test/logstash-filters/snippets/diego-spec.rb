# encoding: utf-8
require 'test/filter_test_helpers'

describe "Diego component logs" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
        #{File.read("src/logstash-filters/snippets/diego.conf")}
      }
    CONFIG
  end

  describe "Rep log parsing rules" do
    when_parsing_log(
      '@source' => { 'program' => 'rep' },
      '@message' => '{"timestamp":"1466769728.520450354","source":"rep","message":"rep.executing-container-operation.starting","log_level":1,"data":{"container-guid":"6dcf9128-3762-4624-839f-0e640cec2ff1-6a9abb10-0757-4bd7-847b-623fb28b4661-9469e7e3-92b9-4305-4a75-882f1b04944d","session":"61"}}'
    ) do

      it "adds bosh nats tag" do
        expect(subject["tags"]).to include "diego/json"
      end

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.parse("2016-06-24T12:02:08.520Z")
      end

      it "sets @timestamp_ns" do
        expect(subject["@timestamp_ns"]).to eq 450354
      end

      it "sets @level" do
        expect(subject["@level"]).to eq "INFO"
      end

      it "parses the message as json" do
        expect(subject["rep"]["data"]["session"]).to eq "61"
      end

      it "sets @message" do
        expect(subject["@message"]).to eq "rep.executing-container-operation.starting"
      end
    end
  end

  describe "alternate formats" do
    context "for rep logs" do
      when_parsing_log(
        '@source' => { 'program' => 'rep' },
        '@message' => '{"timestamp":"2016-06-24T05:02:08.520450354-07:00","source":"rep","message":"rep.executing-container-operation.starting","level":"DEBUG","data":{"container-guid":"6dcf9128-3762-4624-839f-0e640cec2ff1-6a9abb10-0757-4bd7-847b-623fb28b4661-9469e7e3-92b9-4305-4a75-882f1b04944d","session":"61"}}'
      ) do

        it "sets @timestamp from an iso8601 timestamp" do
          expect(subject["@timestamp"]).to eq Time.parse("2016-06-24T12:02:08.520Z")
        end
      end
    end
  end

  describe "BBS log parsing rules" do
    when_parsing_log(
      '@source' => { 'program' => 'bbs' },
      '@message' => '{"timestamp":"1466769728.591343880","source":"bbs","message":"bbs.actual-lrp-handler.start-actual-lrp.completed","log_level":2,"data":{"actual_lrp_instance_key":{"instance_guid":"9469e7e3-92b9-4305-4a75-882f1b04944d","cell_id":"diego_cell-partition-6531e9947fabe4e829e5-0"},"actual_lrp_key":{"process_guid":"6dcf9128-3762-4624-839f-0e640cec2ff1-6a9abb10-0757-4bd7-847b-623fb28b4661","index":0,"domain":"cf-apps"},"net_info":{"address":"10.0.16.19","ports":[{"container_port":8080,"host_port":60036},{"container_port":2222,"host_port":60037}]},"session":"5.594"}}'
    ) do

      it "adds bosh nats tag" do
        expect(subject["tags"]).to include "diego/json"
      end

      it "sets @timestamp" do
        expect(subject["@timestamp"]).to eq Time.parse("2016-06-24T12:02:08.591Z")
      end

      it "sets @timestamp_ns" do
        expect(subject["@timestamp_ns"]).to eq 343880
      end

      it "sets @level" do
        expect(subject["@level"]).to eq "ERROR"
      end

      it "parses the message as json" do
        expect(subject["bbs"]["data"]["net_info"]["address"]).to eq "10.0.16.19"
      end

      it "sets @message" do
        expect(subject["@message"]).to eq "bbs.actual-lrp-handler.start-actual-lrp.completed"
      end
    end
  end
end

