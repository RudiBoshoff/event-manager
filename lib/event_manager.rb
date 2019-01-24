require "csv"

puts 'EventManager Initialized!'

FILE = 'event_attendees.csv'.freeze

def file_exist?
  if File.exist? FILE
    true
  else
    false
  end
end

def display_entire_file(file_to_display)
  contents = File.read file_to_display
  puts contents
end

def display_lines(file_to_display)
  lines = File.readlines file_to_display
  lines.each_with_index do |line, index|
    next if index == 0
    columns = line.split(",")
    name = columns[2]
    p name
  end
end

def display_csv_file(file_to_display)
  contents = CSV.open file_to_display, headers: true, header_converters: :symbol
  contents.each do |column|
    name = column[:first_name]
    zipcode = column[:zipcode]
    puts "#{name} #{zipcode}"
  end
end

if file_exist?
  # display_entire_file FILE
  # display_lines FILE
  display_csv_file FILE
else
  puts "#{FILE} does not exist"
end
