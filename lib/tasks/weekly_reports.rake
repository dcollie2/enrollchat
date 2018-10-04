require 'delivery_windows'

namespace :weekly_reports do
  include Rake::DSL
  include DeliveryWindows

  task :send_emails => :environment do
    unless Rails.configuration.email_delivery == "off"
      if (Rails.configuration.email_delivery == "scheduled" && delivery_window == true) || Rails.configuration.email_delivery == "on"
        if Date.today.wday == 4
          ReportWorker.perform_async()
        end
      end
    end
  end
end
