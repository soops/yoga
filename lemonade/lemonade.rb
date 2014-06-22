#!/usr/bin/env ruby

require 'rainbow'

puts
puts Rainbow("What's the problem?").blue
input = gets.chomp

input.gsub! " my ", " your "
input.gsub! " I ", " you "
input.gsub! " i ", " you "
input.gsub! " me ", " you "
input.gsub! " .", ""

puts
print "oh, so "
print Rainbow("#{input}?").red
puts
puts Rainbow("Just drink some lemonade :D").yellow
puts
