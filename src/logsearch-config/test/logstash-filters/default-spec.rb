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
end
