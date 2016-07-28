# encoding: utf-8
require 'test/filter_test_helpers'

describe "The combined parsing rules" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
    #{File.read('vendor/logsearch-boshrelease/src/logsearch-config/target/logstash-filters-default.conf')}
    #{File.read('target/logstash-filters-default.conf').gsub(/\/var\/vcap\/.*(?=")/, "#{Dir.pwd}/target/deployment_lookup.yml")}
      }
    CONFIG
  end

  describe "when parsing UAA audit logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<14>2016-03-15T14:47:26.151141+00:00 10.0.10.23 vcap.uaa [job=uaa-partition-d28a4b678c048a483acb index=0]  [2016-03-15 14:47:26.151] uaa - 6327 [http-bio-8080-exec-4] ....  INFO --- Audit: TokenIssuedEvent (\'["emails.write","cloud_controller.read","cloud_controller.write","notifications.write","critical_notifications.write","cloud_controller.admin"]\'): principal=autoscaling_service, origin=[caller=autoscaling_service, details=(type=UaaAuthenticationDetails)], identityZoneId=[uaa]'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "source"
      end
      it "adds the uaa-audit tag" do
        expect(subject["tags"]).to include "uaa-audit"
      end
    end
  end

  describe "when parsing firehose logs" do
    context "when parsing CounterEvent metrics" do
      when_parsing_log(
        "@type" => "syslog",
        "@message" => '<6>2016-07-12T15:11:01Z 916d7a73-7f3b-467e-b50e-0e5b07690ea3 doppler[12128]: {"cf_origin":"firehose","delta":5,"deployment":"cf","event_type":"CounterEvent","index":"0","ip":"10.0.16.6","job":"consul_server-partition-6531e9947fabe4e829e5","level":"info","msg":"","name":"udp.sentMessageCount","origin":"MetronAgent","time":"2016-07-12T15:11:01Z","total":318392}'
      ) do

        it "adds the source tag" do
          expect(subject["tags"]).to include "firehose"
        end
      end
    end

    describe "when parsing ValueMetric logs" do
      when_parsing_log(
        "@type" => "syslog",
        "@message" => '<6>2016-07-11T15:36:56Z 916d7a73-7f3b-467e-b50e-0e5b07690ea3 doppler[12128]: {"cf_origin":"firehose","deployment":"cf","event_type":"ValueMetric","index":"0","ip":"10.0.16.18","job":"diego_brain-partition-6531e9947fabe4e829e5","level":"info","msg":"","name":"memoryStats.numBytesAllocatedHeap","origin":"nsync_bulker","time":"2016-07-11T15:36:56Z","unit":"count","value":1.695088e+06}'
      ) do

        it "adds the source tag" do
          expect(subject["tags"]).to include "firehose"
        end
      end
    end

    describe "when parsing ContainerMetric logs" do
      when_parsing_log(
        "@type" => "syslog",
        "@message" => '<6>2016-07-12T15:10:56Z 916d7a73-7f3b-467e-b50e-0e5b07690ea3 doppler[12128]: {"cf_app_id":"574069a6-bc4f-4d2b-9ad1-a0f7c7f494d6","cf_app_name":"apps-manager-js","cf_org_id":"ce88b618-b2b6-4526-ad87-b643c2323d37","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"5936d220-f4dc-4ae4-9f38-f00042e5b2a2","cf_space_name":"system","cpu_percentage":0.03455660811827167,"deployment":"cf","disk_bytes":9920512,"event_type":"ContainerMetric","index":"0","instance_index":0,"ip":"10.0.16.19","job":"diego_cell-partition-6531e9947fabe4e829e5","level":"info","memory_bytes":7327744,"msg":"","origin":"rep","time":"2016-07-12T15:10:56Z"}'
      ) do

        it "adds the source tag" do
          expect(subject["tags"]).to include "firehose"
        end
      end
    end

    describe "when parsing LogMessage logs" do
      when_parsing_log(
        "@type" => "syslog",
        "@message" => '<6>2016-07-12T15:11:32Z 916d7a73-7f3b-467e-b50e-0e5b07690ea3 doppler[12128]: {"cf_app_id":"4c5a5ed9-c7af-4ae2-ad18-cf6625c91e26","cf_app_name":"notifications","cf_org_id":"ce88b618-b2b6-4526-ad87-b643c2323d37","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"8e32563d-264c-435f-a3ea-d5843729ad0e","cf_space_name":"notifications-with-ui","deployment":"cf","event_type":"LogMessage","index":"0","ip":"10.0.16.19","job":"diego_cell-partition-6531e9947fabe4e829e5","level":"info","message_type":"OUT","msg":"[METRIC] {\"kind\":\"gauge\",\"payload\":{\"name\":\"notifications.queue.retry\",\"tags\":{\"count\":\"1\"},\"value\":0}}","origin":"rep","source_instance":"0","source_type":"APP","time":"2016-07-12T15:11:32Z","timestamp":1468336292051384719}'
      ) do

        it "adds the source tag" do
          expect(subject["tags"]).to include "firehose"
        end
      end
    end
  end

  describe "when parsing diego component logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<13>2016-06-29T10:04:00.221087+00:00 10.10.114.110 vcap.rep [job=cell_z1 index=75]  {"timestamp":"1467194640.220978260","source":"rep","message":"rep.sync-drivers.discover.Discovering drivers in [/var/vcap/data/voldrivers]","log_level":1,"data":{"session":"6.1705"}}') do

      it "adds the diego/json tag" do
        expect(subject["tags"]).to include "diego/json"
      end

      it "sets @metadata.index to rep" do
        expect(subject["@metadata"]["index"]).to eq "rep"
      end
    end
  end
end
