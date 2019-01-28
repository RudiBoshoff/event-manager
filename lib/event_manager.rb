require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

FILE = 'event_attendees.csv'.freeze
LETTER = "form_letter.erb"

def file_exist?
  if File.exist? FILE
    true
  else
    false
  end
end

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
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def display_csv_file(file_to_display, _civic_info)
  contents = CSV.open file_to_display, headers: true, header_converters: :symbol

  template_letter = File.read LETTER
  erb_template = ERB.new template_letter

  contents.each do |column|
    id = column[0]
    name = column[:first_name]

    zipcode = clean_zipcode(column[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    Dir.mkdir("output") unless Dir.exists? "output"
    filename = "output/thanks_#{id}.html"
    File.open(filename,"w") do |file|
      file.puts form_letter
    end
  end
end

if file_exist?
  display_csv_file(FILE, civic_info)
else
  puts "#{FILE} does not exist"
end
