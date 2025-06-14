require 'net/http'
require 'uri'
require 'json'
require 'logger'
require 'date'
require 'csv'

# --- Configuration ---
# This is the internal URL to reach Home Assistant Core API from an add-on
HA_API_URL_BASE = "http://supervisor/core/api"
SUPERVISOR_TOKEN = ENV['SUPERVISOR_TOKEN']
ENTITY_ID = "sensor.word_of_the_day_addon"

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

unless SUPERVISOR_TOKEN && !SUPERVISOR_TOKEN.empty?
  logger.error("SUPERVISOR_TOKEN environment variable not found or empty.")
  logger.error("Ensure 'homeassistant_api: true' (or 'hassio_api: true') is in your add-on's config.yaml")
  exit 1 # Exit if the token is missing
end

day_number = Date.today.yday
csv_file_path = '/words.csv'
target_line_number = day_number
line_data = nil

begin
  unless File.exist?(csv_file_path)
    logger.error("Error: File not found at #{csv_file_path}")
    exit 1
  end

  CSV.foreach(csv_file_path).with_index do |row, index|
    if (index + 1) == target_line_number
      line_data = row
      break
    end
  end

  if line_data
    logger.info("Raw line data from CSV: #{line_data.inspect}")
  else
    logger.warn("The file '#{File.basename(csv_file_path)}' has fewer than #{target_line_number} lines. No data to update sensor with.")
  end

rescue CSV::MalformedCSVError => e
  logger.error("Error: Could not parse the CSV file. It might be malformed.")
  logger.error("Details: #{e.message}")
  exit 1 # Or handle more gracefully depending on requirements
rescue StandardError => e
  logger.error("An unexpected error occurred during CSV processing: #{e.message}")
  exit 1 # Or handle more gracefully
end

my_value = "#{line_data[0]}: #{line_data[1]} eg. #{line_data[2]}"
attributes = {
  "friendly_name": "Word of the Day",
  "last_updated_by_addon": DateTime.now.iso8601,
  "ruby_version": RUBY_VERSION,
  "word_of_the_day": line_data[0],
  "definition": line_data[1],
  "example_sentence": line_data[2]
}

# --- Prepare the API Request ---
uri = URI.parse("#{HA_API_URL_BASE}/states/#{ENTITY_ID}")

request = Net::HTTP::Post.new(uri.path)
request['Authorization'] = "Bearer #{SUPERVISOR_TOKEN}"
request['Content-Type'] = 'application/json'

payload = {
  state: my_value.to_s, # Ensure state is a string or number
  attributes: attributes
}
request.body = payload.to_json

logger.info("Attempting to update entity: #{ENTITY_ID} with value: \"#{my_value}\"")
logger.debug("Payload: #{request.body}") # Use debug for verbose output

# --- Send the Request ---
MAX_RETRIES = 3
RETRY_DELAY = 5 # seconds
retries = 0

loop do
  begin
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10 # seconds
    http.read_timeout = 10 # seconds
    response = http.request(request)

    logger.info("Response Code: #{response.code}")

    if response.is_a?(Net::HTTPSuccess) # Covers 200-299 status codes
      logger.info("Successfully updated entity #{ENTITY_ID}. (#{retries}/#{MAX_RETRIES})")
      break # Exit loop on success
    else
      logger.error("Failed to update entity #{ENTITY_ID}. (#{retries}/#{MAX_RETRIES})")
      logger.error("Status: #{response.code} - #{response.message}. Response Body: #{response.body}")
      break # Exit loop on non-success HTTP response
    end

  rescue StandardError => e # Catch any StandardError from the API request block
    retries += 1
    logger.warn("Error during API request: #{e.class} - #{e.message}. Retry #{retries}/#{MAX_RETRIES}. Waiting #{RETRY_DELAY}s...")
    if retries <= MAX_RETRIES # Allow up to MAX_RETRIES retry attempts (1 initial + MAX_RETRIES retries)
      sleep RETRY_DELAY
    else
      logger.error("Max retries (#{MAX_RETRIES}) reached for API request. Last error: #{e.class} - #{e.message}")
      logger.error("Backtrace for last error:\n#{e.backtrace.join("\n")}")
      break # Exit loop after max retries
    end
  end
end

sleep(14400)