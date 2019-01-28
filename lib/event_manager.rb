require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

puts 'EventManager Initialized!'

FILE = 'event_attendees.csv'.freeze

def file_exist?
  if File.exist? FILE
    true
  else
    false
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislators_string = legislator_names.join(', ')
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def display_csv_file(file_to_display, _civic_info)
  contents = CSV.open file_to_display, headers: true, header_converters: :symbol

  contents.each do |column|
    name = column[:first_name]

    zipcode = clean_zipcode(column[:zipcode])

    legislator = legislators_by_zipcode(zipcode)

    puts "#{name} #{zipcode} #{legislator}"
    puts ''
  end
end

if file_exist?
  display_csv_file(FILE, civic_info)
else
  puts "#{FILE} does not exist"
end
