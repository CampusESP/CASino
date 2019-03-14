require 'builder'
require 'faraday'
require 'faraday_middleware'

class CASino::ServiceTicket::SingleSignOutNotifier
  def initialize(service_ticket)
    @service_ticket = service_ticket
  end

  def notify
    send_notification @service_ticket.service, build_xml
  end

  private

  def build_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.samlp :LogoutRequest,
      'xmlns:samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
      'xmlns:saml' => 'urn:oasis:names:tc:SAML:2.0:assertion',
      ID: SecureRandom.uuid,
      Version: '2.0',
      IssueInstant: Time.now do |logout_request|
      logout_request.saml :NameID, '@NOT_USED@'
      logout_request.samlp :SessionIndex, @service_ticket.ticket
    end
    xml.target!
  end

  def send_notification(url, xml)
    Rails.logger.info "Sending Single Sign Out notification for ticket '#{@service_ticket.ticket}'"

    server, path = split_url(url)
    connection = Faraday.new(server) do |conn|
      conn.use FaradayMiddleware::FollowRedirects
      conn.adapter Faraday.default_adapter
    end
    result = connection.post(path, "logoutRequest=#{URI.encode(xml)}") do |request|
      request.options[:timeout] = CASino.config.service_ticket[:single_sign_out_notification][:timeout]
    end
    if !result.success?
      Rails.logger.warn "Service #{url} responded to logout notification with code '#{result.status}'!"
      return false
    elsif result.env.method != :post
      Rails.logger.warn "Service #{url} responded to logout notification with an invalid redirect to '#{result.env.url}'!"
      return false
    end
    Rails.logger.info "Logout notification successfully posted to #{url}."
    true
  rescue Faraday::Error::ClientError, Errno::ETIMEDOUT => error
    Rails.logger.warn "Failed to send logout notification to service #{url} due to #{error}"
    false
  end

  def split_url(url)
    uri = URI.parse(url)
    uri2 = uri.dup
    uri.path = ''
    uri.query = uri.fragment = nil
    [uri.to_s, (uri2 - uri).to_s]
  end
end
