#! /usr/bin/env ruby

require 'rubygems'
require 'icalendar'
require 'ruby_spark'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'Date'


#Open a calendar
calendars = nil
open("CALENDAR HERE") do |cal|
  #Parses ics file into calendars
  calendars = Icalendar.parse(cal)
end

calendars.each do |calendar|

  calendar.events.each do |event|

    puts event.dtstart

    #Parses Datetime from .ics
    cleanTime = DateTime.strptime(event.dtstart.to_s, "%Y-%m-%d %H:%M:%S %z")

    puts cleanTime

    ##TODO: Fix this logic
    if cleanTime > DateTime.now < DateTime.now + 60
      puts "#{event.summary} starts at: #{event.dtstart} and ends at #{event.dtend}"
    end

  end

end
