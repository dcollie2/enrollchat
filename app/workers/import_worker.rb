class ImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(filepath)
    Section.import(filepath)
  end
end
