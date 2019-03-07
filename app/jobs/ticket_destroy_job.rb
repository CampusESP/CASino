class TicketDestroyJob < ActiveJob::Base
  include CASino::TicketGrantingTicketProcessor

  queue_as :default

  def perform(ticket_granting_ticket, user_agent)
    remove_ticket_granting_ticket(ticket_granting_ticket, user_agent)
  end
end
