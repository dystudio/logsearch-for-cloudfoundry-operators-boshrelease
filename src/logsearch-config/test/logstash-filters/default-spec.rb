# encoding: utf-8
require 'test/filter_test_helpers'

describe "The combined parsing rules" do

  before(:all) do
    load_filters <<-CONFIG
      filter {
    #{File.read('vendor/logsearch-boshrelease/src/logsearch-config/target/logstash-filters-default.conf')}
    #{File.read('target/logstash-filters-default.conf')}
      }
    CONFIG
  end

  describe 'when parsing firehose logs' do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<6>2015-03-17T01:24:23Z jumpbox.xxxxxxx.com doppler[6375]: {"cf_app_id":"b732c465-0536-4014-b922-165eb38857b2","level":"info","message_type":"OUT","msg":"Stopped app instance (index 0) with guid b732c465-0536-4014-b922-165eb38857b2","source_instance":"7","source_type":"DEA","time":"2015-03-17T01:24:23Z"}'
    ) do

      it "adds the firehose tag" do
        expect(subject["tags"]).to include 'firehose'
      end
    end
  end

  describe "when parsing UAA audit logs" do
    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<14>2016-03-15T14:47:26.151141+00:00 10.0.10.23 vcap.uaa [job=uaa-partition-d28a4b678c048a483acb index=0]  [2016-03-15 14:47:26.151] uaa - 6327 [http-bio-8080-exec-4] ....  INFO --- Audit: TokenIssuedEvent (\'["emails.write","cloud_controller.read","cloud_controller.write","notifications.write","critical_notifications.write","cloud_controller.admin"]\'): principal=autoscaling_service, origin=[caller=autoscaling_service, details=(type=UaaAuthenticationDetails)], identityZoneId=[uaa]'
    ) do

      it "adds the uaa-audit tag" do
        expect(subject["tags"]).to include "uaa-audit"
      end
    end
  end
end
