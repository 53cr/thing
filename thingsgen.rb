require 'rubygems'
require 'yaml'

properties = [:size, :calories, :calories_from_fat, :total_fat, :saturated_fat, :cholesterol, :sodium, :total_carbs, :fiber, :sugars, :protein, :vitamin_a, :vitamin_c, :calcium, :iron]

items = {}

puts "Name of item?"
name = gets.strip

while name != "STOP"

  items[name] = {}
  
  properties.each do |prop|
    puts prop
    items[name][prop] = gets.strip
  end
  
  puts "Name of item?"
  name = gets.strip
end

File.open('things.yml','w') do |file|
  file.puts YAML.dump(items)
end
