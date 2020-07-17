# frozen_string_literal: true

require 'tmpdir'
require 'spec_helper'
require_relative '../lib/dogbreed'

RSpec.describe DogBreed do
  # zkusit dat inicializaci noveho objekdu do bloku before(:example)
  before(:example) do
    name = 'hound'
    images = ['https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg', 'https://images.dog.ceo/breeds/hound-afghan/n02088094_1007.jpg']
    @breed = DogBreed.new(name, images)
  end

  context 'initializing the instance' do
    it 'creates the attributes' do
      expect(@breed.name).to eq('hound')
      images = ['https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg', 'https://images.dog.ceo/breeds/hound-afghan/n02088094_1007.jpg']
      expect(@breed.images).to eq(images)
      expect(@breed.filename).to eq('hound.csv')
    end
  end

  describe '#save' do
    it 'saves data to csv' do
      temp = Dir.tmpdir
      expect(@breed.save(temp)).to eq(nil)
      expect(File).to exist("#{temp}/#{@breed.filename}")
      csv_text = ["breed name,image\n",
                  "hound,https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg\n",
                  "hound,https://images.dog.ceo/breeds/hound-afghan/n02088094_1007.jpg\n"]
      expect(File.open("#{temp}/#{@breed.filename}").readlines).to eq(csv_text)
    end
  end
end
