# frozen_string_literal: true

require 'csv'

# region used class and methods
class DogBreed
  attr_accessor :name, :images, :file_creation_date, :filename
  def initialize(name, images)
    self.name = name
    self.images = images
    self.filename = "#{name}.csv"
  end

  # save info to CSV file
  def save(directory)
    CSV.open("#{directory}/#{filename}", 'wb') do |csv|
      csv << ['breed name', 'image']
      images&.each { |image| csv << [name, image] }
    end
    self.file_creation_date = File.ctime(filename)
    puts "File #{filename} was created"
  rescue IOError, SystemCallError => e
    puts "File #{filename} was not created - #{e.message}"
  end
end
