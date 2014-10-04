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

#TODO: handle all day events.

#create new array
events = []

calendars.each do |calendar|

  calendar.events.each do |event|

    #Parses Datetime from .ics
    startTime = DateTime.strptime(event.dtstart.to_s, "%Y-%m-%d %H:%M:%S %z")
    endTime = DateTime.strptime(event.dtend.to_s, "%Y-%m-%d %H:%M:%S %z")

    #Only selects event if current time is between event start and event end
    if Time.now.to_i < endTime.to_i and Time.now.to_i > startTime.to_i

      #put event into array
      events << {event: event.summary, location: event.location}
      puts events
    end

  end

end
