
class CASino::LogoutRule < CASino::ApplicationRecord
  validates :name, presence: true
  validates :url, uniqueness: true, presence: true

  def self.apply(service_url)
    where(enabled: true)
      .order(order: :asc, id: :asc)
      .lazy.map {|rule| rule.apply(service_url)}
      .find(&:itself) || service_url
  end

  def apply(service_url)
    service_url.match(Regexp.new(regex, true)) { url }
  end
end
