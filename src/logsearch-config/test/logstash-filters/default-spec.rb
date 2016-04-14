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

  describe "when parsing CounterEvent metrics" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<6>2016-04-12T10:16:37Z 95c570e0-c2eb-4f43-b33e-69a456fe96f0 doppler[4176]: {"cf_origin":"firehose","delta":10,"event_type":"CounterEvent","level":"info","msg":"","name":"dropsondeMarshaller.counterEventMarshalled","origin":"MetronAgent","time":"2016-04-12T10:16:37Z","total":3770256}'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "CounterEvent"
      end
    end
  end

  describe "when parsing ValueMetric logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<6>2016-04-12T09:50:54Z 95c570e0-c2eb-4f43-b33e-69a456fe96f0 doppler[4176]: {"cf_origin":"firehose","event_type":"ValueMetric","level":"info","msg":"","name":"logSenderTotalMessagesRead","origin":"p-rabbitmq","time":"2016-04-12T09:50:54Z","unit":"count","value":123}'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "ValueMetric"
      end
    end
  end

  describe "when parsing ContainerMetric logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<6>2016-04-12T10:18:19Z 0156bb68-1673-415f-a48c-f0783e44d156 doppler[4188]: {"cf_app_id":"6a4fa603-d03d-4d5d-9efc-73c4e815e053","cf_app_name":"notifications-ui","cf_org_id":"b152d3f9-ea0a-487a-b00c-688185a6ebcd","cf_org_name":"system","cf_origin":"firehose","cf_space_id":"0f7c1e0e-e9b5-4afe-a095-71a058afcb1f","cf_space_name":"notifications-with-ui","cpu_percentage":0.019206287207808037,"disk_bytes":17309696,"event_type":"ContainerMetric","instance_index":0,"level":"info","memory_bytes":11165696,"msg":"","origin":"rep","time":"2016-04-12T10:18:19Z"}'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "ContainerMetric"
      end
    end
  end


  describe "when parsing LogMessage logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<6>2016-04-12T10:04:31Z 95c570e0-c2eb-4f43-b33e-69a456fe96f0 doppler[4176]: {"cf_app_id":"cfcb2d5a-244a-4c51-b22b-8562d13822a9","cf_app_name":"chatty-app","cf_org_id":"8b877d32-d147-4729-a8be-33df22f9221e","cf_org_name":"test","cf_origin":"firehose","cf_space_id":"d58e7bc0-72d0-45ef-9fdc-cdd168dee98b","cf_space_name":"test","event_type":"LogMessage","level":"info","message_type":"OUT","msg":"{\"data\":\"di7xex8gsfer85yykodbbi97qtaf3xrz\",\"time\":\"1460455471\"}","origin":"rep","source_instance":"3","source_type":"APP","time":"2016-04-12T10:04:31Z","timestamp":1460455471700095202}'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "LogMessage"
      end
    end
  end
end
