require File.expand_path('../helper', __FILE__)
class HakkaLabsTest < Service::TestCase
  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
    data = {
      'secret' => 'hakka',
      'token'  => 'labs'
    }
    @svc = service(data, payload)
  end

  def test_push_as_json_with_secret
    @stubs.post "/api/webhooks" do |env|
      assert_match /json/, env[:request_headers]['content-type']
      assert_equal 2, env[:request_headers].keys.select { |k| k.match("X-GitHub")}.size
      assert_equal 'www.hakkalabs.co', env[:url].host
      assert_equal 'sha1='+OpenSSL::HMAC.hexdigest(Service::Web::HMAC_DIGEST,
                                        'hakka', env[:body]),
        env[:request_headers]['X-Hub-Signature']
      assert_equal "labs", env[:params]["token"]
      assert_equal "github", env[:params]["service"]
      assert_equal payload, JSON.parse(env[:body])
      [200, {}, '']
    end

    @svc.receive_event
  end

  def test_log_message
    assert_match /^\[[^\]]+\] 200 hakkalabs\/push \{/, @svc.log_message(200)
  end

  def service(*args)
    super Service::HakkaLabs, *args
  end
end
