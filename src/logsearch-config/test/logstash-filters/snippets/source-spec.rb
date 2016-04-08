# encoding: utf-8
require 'test/filter_test_helpers'

describe "Extracting @source information" do

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

      it "adds the deployment tagger tag" do
        expect(subject["tags"]).to include "auto_deployment"
      end

      it "sets @source.deployment" do
        expect(subject["@source"]["deployment"]).to eq "Unknown"
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

  describe "Deployment lookup" do
    context "when source is a CF job" do
      when_parsing_log(
        "@source" => { "job" => "diego_cell-123123123" }
      ) do

        it "adds the deployment tagger tag" do
          expect(subject["tags"]).to include "auto_deployment"
        end

        it "sets @source.deployment" do
          expect(subject["@source"]["deployment"]).to eq "CF"
        end
      end
    end

    context "when source is a rabbitmq job" do
      when_parsing_log(
        "@source" => { "job" => "rabbitmq-broker-123123123" }
      ) do

        it "adds the deployment tagger tag" do
          expect(subject["tags"]).to include "auto_deployment"
        end

        it "sets @source.deployment" do
          expect(subject["@source"]["deployment"]).to eq "rabbitmq"
        end
      end
    end

    context "when source is a mysql job" do
      when_parsing_log(
        "@source" => { "job" => "proxy-partition-123123123" }
      ) do

        it "adds the deployment tagger tag" do
          expect(subject["tags"]).to include "auto_deployment"
        end

        it "sets @source.deployment" do
          expect(subject["@source"]["deployment"]).to eq "mysql"
        end
      end
    end
    context "when source is a redis job" do
      when_parsing_log(
        "@source" => { "job" => "dedicated-node-partition-123123123" }
      ) do

        it "adds the deployment tagger tag" do
          expect(subject["tags"]).to include "auto_deployment"
        end

        it "sets @source.deployment" do
          expect(subject["@source"]["deployment"]).to eq "redis"
        end
      end
    end

    context "when source is a logsearch job" do
      when_parsing_log(
        "@source" => { "job" => "kibana-123123123" }
      ) do

        it "adds the deployment tagger tag" do
          expect(subject["tags"]).to include "auto_deployment"
        end

        it "sets @source.deployment" do
          expect(subject["@source"]["deployment"]).to eq "logsearch"
        end
      end
    end
  end
end
