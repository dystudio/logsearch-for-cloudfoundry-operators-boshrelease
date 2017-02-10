# encoding: utf-8
require 'test/filter_test_helpers'

describe "Extracting @source information" do
  describe 'support for format shipped by https://github.com/cloudfoundry/syslog-release#format' do
    before(:all) do
      load_filters <<-CONFIG
        filter {
          #{File.read("vendor/logsearch-boshrelease/src/logsearch-config/target/logstash-filters-default.conf")}
          #{File.read("src/logstash-filters/snippets/source.conf")}
        }
      CONFIG
    end

    when_parsing_log(
      "@type" => "syslog",
      "@message" => '<14>1 2017-01-25T13:25:03.18377Z 192.0.2.10 etcd - - [instance@47450 director="test-env" deployment="cf" group="diego_database" az="us-west1-a" id="83bd66e5-3fdf-44b7-bdd6-508deae7c786"] [INFO] the leader is [https://diego-database-0.etcd.service.cf.internal:4001]'
    ) do

      it "adds the source tag" do
        expect(subject["tags"]).to include "source"
      end

      it "sets @source.director" do
        expect(subject["@source"]["director"]).to eq "test-env"
      end

      it "sets @source.deployment" do
        expect(subject["@source"]["deployment"]).to eq "cf"
      end

      it "sets @source.vm" do
        expect(subject["@source"]["vm"]).to eq "diego_database/83bd66e5-3fdf-44b7-bdd6-508deae7c786"
      end

      it "sets @source.group" do
        expect(subject["@source"]["group"]).to eq "diego_database"
      end

      it "sets @source.id" do
        expect(subject["@source"]["id"]).to eq "83bd66e5-3fdf-44b7-bdd6-508deae7c786"
      end

      it "sets @source.ip" do
        expect(subject["@source"]["ip"]).to eq "192.0.2.10"
      end

      it "sets @source.program" do
        expect(subject["@source"]["program"]).to eq "etcd"
      end

      it "removes syslog_sd_id" do
        expect(subject.to_hash.keys).to_not include "syslog_sd_id"
      end

      it "removes syslog_sd_params" do
        expect(subject.to_hash.keys).to_not include "syslog_sd_params"
      end

      it "removes parsed fields from @message" do
        expect(subject["@message"]).to eq '[INFO] the leader is [https://diego-database-0.etcd.service.cf.internal:4001]'
      end
    end
  end

  describe 'parsing older syslog forwarding format' do
    before(:all) do
      # change path of the source.deployment translation table so it works in test
      load_filters <<-CONFIG
        filter {
          #{File.read("src/logstash-filters/snippets/source.conf").gsub(/\/var\/vcap\/.*(?=")/, "#{Dir.pwd}/target/deployment_lookup.yml")}
        }
      CONFIG
    end

    describe "CloudController syslog" do
      when_parsing_log(
        "@type" => "syslog",
        "syslog_program" => "vcap.cloud_controller_ng",
        "syslog_hostname" => "10.10.81.5",
        "@message" => '[job=api_z2 index=1]  {"timestamp":1458648262.0071645,"message":"Statsd: cc.requests.outstanding:-1|c\ncc.requests.completed:1|c\ncc.http_status.2XX:1|c","log_level":"debug","source":"statsd.client","data":{},"thread_id":47073447296880,"fiber_id":47073444675740,"process_id":3255,"file":"/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/vendor/bundle/ruby/2.2.0/gems/statsd-ruby-1.2.1/lib/statsd.rb","lineno":254,"method":"send_to_socket"}'
      ) do

        it "adds the source tag" do
          expect(subject["tags"]).to include "source"
        end

        it "sets @source.vm" do
          expect(subject["@source"]["vm"]).to eq "api_z2/1"
        end

        it "sets @source.job" do
          expect(subject["@source"]["job"]).to eq "api_z2"
        end

        it "sets @source.index" do
          expect(subject["@source"]["index"]).to eq 1
        end

        it "sets @source.ip" do
          expect(subject["@source"]["ip"]).to eq "10.10.81.5"
        end

        it "sets @source.program" do
          expect(subject["@source"]["program"]).to eq "cloud_controller_ng"
        end

        it "removes parsed fields from @message" do
          expect(subject["@message"]).to eq '{"timestamp":1458648262.0071645,"message":"Statsd: cc.requests.outstanding:-1|c\ncc.requests.completed:1|c\ncc.http_status.2XX:1|c","log_level":"debug","source":"statsd.client","data":{},"thread_id":47073447296880,"fiber_id":47073444675740,"process_id":3255,"file":"/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/vendor/bundle/ruby/2.2.0/gems/statsd-ruby-1.2.1/lib/statsd.rb","lineno":254,"method":"send_to_socket"}'
        end

      end
    end

    context "when log does not have job and index params" do
      when_parsing_log(
        "@type" => "syslog",
        "syslog_program" => "vcap.cloud_controller_ng",
        "syslog_hostname" => "10.10.81.5",
        "@message" => '{"timestamp":1458648262.0071645,"message":"Statsd: cc.requests.outstanding:-1|c\ncc.requests.completed:1|c\ncc.http_status.2XX:1|c","log_level":"debug","source":"statsd.client","data":{},"thread_id":47073447296880,"fiber_id":47073444675740,"process_id":3255,"file":"/var/vcap/packages/cloud_controller_ng/cloud_controller_ng/vendor/bundle/ruby/2.2.0/gems/statsd-ruby-1.2.1/lib/statsd.rb","lineno":254,"method":"send_to_socket"}'
      ) do

        it "does not add the source tag" do
          expect(subject["tags"]).to be_nil
        end
      end
    end
  end
end
