class Service::HakkaLabs < Service::HttpPost
  password :token
  password :secret

  default_events :push

  url 'https://www.hakkalabs.co/api/webhooks'
  logo_url 'https://www.hakkalabs.co/assets/logo-black-large2x.png'

  maintained_by :github => 'smothers'

  supported_by :web => 'https://www.hakkalabs.co',
               :email => 'support@hakkalabs.co',
               :github => 'smothers'

  def receive_event
    http.headers['X-GitHub-Event'] = event.to_s
    http.headers['X-GitHub-Delivery'] = delivery_guid.to_s

    res = deliver self.class.url + "?token=#{data['token']}&service=github",
      :secret => data['secret']

    unless res.status == 200
      raise_config_error "Invalid HTTP Response: #{res.status}"
    end
  end

  def original_body
    payload
  end
end
