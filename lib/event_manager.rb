require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

EVENT_ATTENDEES = 'event_attendees.csv'.freeze
TEMPLATE_LETTER = 'form_letter.erb'.freeze

# Replaces zipcode if blank
# adds zeros if shorter than 5 digits
# only accepts a maximum of 5 digits for zipcode
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

# Uses zipcode to determine legislators from google civic api
def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir 'output' unless Dir.exist? 'output'
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    # writes the template letter to the file
    file.puts form_letter
  end
end

def display_csv_file(file_to_display, _civic_info)
  contents = CSV.open file_to_display, headers: true, header_converters: :symbol

  if File.exist?(TEMPLATE_LETTER)
    template_letter = File.read TEMPLATE_LETTER
    erb_template = ERB.new template_letter
  else
    puts "#{TEMPLATE_LETTER} does not exist"
    exit
  end

  analyse_contents(contents, erb_template)
end

def analyse_contents(contents, erb_template)
  contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letters(id, form_letter)
  end
end

if File.exist?(EVENT_ATTENDEES)
  display_csv_file(EVENT_ATTENDEES, civic_info)
else
  puts "#{EVENT_ATTENDEES} does not exist"
  exit
end
