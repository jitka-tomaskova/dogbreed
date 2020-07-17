# frozen_string_literal: true

# program for retrieving data from API DogBreed
require 'csv'
require 'json'
require 'net/http'
require 'thread/pool'
require_relative 'dogbreed'

# region set up configuration
config = {}
config[:url] = 'https://dog.ceo/api/breed/*/images'
config[:thread_number] = 5
config[:directory] = File.dirname(__FILE__)
# endregion

# log creation of csv files to json
def log(array)
  filename = 'updated_at.json'
  File.open(filename, 'wb') do |file|
    array.each_with_index do |breed, i|
      file.puts ',' if i != 0
      file.print JSON.generate([breed.filename, breed.file_creation_date&.strftime('%Y-%m-%d %H:%M:%S.%L')])
    end
  end
  puts "File #{filename} was created"
end
# endregion

# region process dog breeds
# check whether there is any parameter
if ARGV.empty?
  puts 'There is no parameter given'
  puts 'Usage: ruby dogbreed.rb BREEDS'
  puts 'BREEDS is array of breed names'
  puts 'Example: ruby dogbreed.rb boxer bulldog'
  exit(1)
end

# list arguments
dog_breeds_list = ARGV.to_a
print 'Arguments given: '

# initialize auxiliary objects
p dog_breeds_list
json = []
dog_breeds = []

# create thread pool
pool = Thread.pool(config[:thread_number])

# gain data from API, add it to array
dog_breeds_list.each do |breed|
  pool.process do
    url = config[:url].sub('*', breed.to_s.downcase)
    begin
      response = Net::HTTP.get_response(URI(url))
      if response.code.to_i >= 200 && response.code.to_i < 300
        json << [breed, response.body]
        puts "Information about #{breed} were retrieved (#{response.code})"
      else
        json << [breed, nil]
        puts "information about #{breed} were not retrieved (#{response.code})"
      end
    rescue StandardError => e
      json << [breed, nil]
      puts "information about #{breed} were not retrieved - #{e.message}"
    end
  end
end
pool.shutdown

# create object instances
json.each do |file|
  dog_breeds << if file[1].nil?
                  DogBreed.new(file[0], nil)
                else
                  DogBreed.new(file[0], JSON.parse(file[1])['message'])
                end
end

# create csv files
dog_breeds.each do |breed|
  breed.save(config[:directory])
end

# create json file
log(dog_breeds)

# endregion
