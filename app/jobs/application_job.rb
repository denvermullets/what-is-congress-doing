class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # missing key error
  rescue_from Congress::Api::MissingApiKeyError do |error|
    Rails.logger.error("Missing API Key: #{error.message}")
    raise error
  end

  # API request errors
  rescue_from Congress::Api::ApiRequestError do |error|
    Rails.logger.warn("API Request Failed: #{error.message}")
    raise error
  end

  # unexpected errors
  rescue_from StandardError do |error|
    Rails.logger.error("Unhandled Job Error: #{error.message}")
    raise error
  end
end
