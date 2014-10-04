#! /usr/bin/env ruby

require 'rubygems'
require 'icalendar'
require 'ruby_spark'
require 'active_support'
require 'active_support/core_ext'
require 'open-uri'
require 'Date'

#Info
NAME = "Kevin"
TZONE = "America/Los_Angeles"
SPARK_ID = ENV['SPARK_ID']
SPARK_TOKEN = ENV['SPARK_TOKEN']

#create new array
timeEvents = []
alldayEvents = []

#ICS URLs
#URLS = ENV['ICS_URL_LIST']
URLS = [
  "https://www.google.com/calendar/ical/kevin%40kevinchau.org/private-45154983dbade5f9e4f3c0be9b0b7ca9/basic.ics",
  "https://www.google.com/calendar/ical/kevin%40divshot.com/private-7aeadab3226a9d184f5734b5be8c990b/basic.ics",
  "https://www.google.com/calendar/ical/chaukevin%40gmail.com/private-8fcae95a29eccde6e9d5bd8649b29e5b/basic.ics"
]

### Parse all calendar events ###

#Open a calendar
calendars = nil

URLS.each do |url|

  open(url) do |cal|

    #Parses ics file into calendars
    calendars = Icalendar.parse(cal)
  end


  calendars.each do |calendar|

    calendar.events.first(15).each do |event|

      #set vars for start and end time
      start_time = event.dtstart.value
      end_time = event.dtend.value


      #Determine if event is timed or all-day
      if event.dtstart.value.is_a?(Date)

        #do stuff for all day event
        if Date.today.in_time_zone(TZONE) >= start_time.in_time_zone(TZONE) && Date.today.in_time_zone(TZONE) <= end_time.in_time_zone(TZONE)

          #add event to array
          alldayEvents << {event:event.summary, location: event.location}

        end

      elsif event.dtstart.value.is_a?(ActiveSupport::TimeWithZone)

        #do stuff for time event
        if Time.now >= start_time && Time.now <= end_time

          #add event to array
          timeEvents << {event: event.summary, location: event.location, eventEnd: event.dtend.in_time_zone('America/Los_Angeles').strftime("%I:%M %p")}

        end

      end

    end

  end

end

### Events Logic ###

#Timed event handling

#TODO: Choose event that ends later

#if there is more than 1 all-day event
if timeEvents.length > 1

  #select based on time
  if Time.now.min.odd?
    timeEvent = timeEvents[0]
  else
    timeEvent = timeEvents[1]
  end

elsif

  #if just one, pick first
  timeEvent = timeEvents.first

else

  timeEvent = nil

end

#All day event handling

if alldayEvents.length > 1

  #pick one based on time
  if Time.now.min.odd?
    dayEvent = alldayEvents[0]
  else
    dayEvent = alldayEvents[1]
  end

elsif alldayEvents.length == 1

  dayEvent = alldayEvents.first

else

  dayEvent = nil

end

#Events Display

#TODO: Build logic to determine free at

#if no events
if dayEvent.nil? && timeEvent.nil?
  line0 = "#{NAME} is Currently:".truncate(20)
  line1 = "  Not Busy".truncate(20)
  line2 = "Come say hello!".truncate(20)
  line3 = "Updated:#{Time.now.in_time_zone(TZONE).strftime("%I:%M %p")}".truncate(20)

#if time event ONLY
elsif timeEvent && dayEvent.nil?
  line0 = "#{NAME} is at:".truncate(20)
  line1 = "#{timeEvent[:event]}".truncate(20)
  line2 = "#{timeEvent[:location]}".truncate(20)
  line3 = "Ends at #{timeEvent[:eventEnd]}".truncate(20)

#if both time event and all-day event
elsif timeEvent && dayEvent
  line0 = "#{NAME} is at:".truncate(20)
  line1 = "#{timeEvent[:event]}".truncate(20)
  line2 = "#{timeEvent[:location]}".truncate(20)
  line3 = "(#{dayEvent[:event]}".truncate(19) + ")"

#if all-day event ONLY
elsif dayEvent && timeEvent.nil?
  line0 = "If Kevin is here, he".truncate(20)
  line1 = "isn't busy. Say Hi!".truncate(20)
  line2 = "   All-Day Event:".truncate(20)
  line3 = "#{dayEvent[:event]}".truncate(20)

end

payload = "#{line0}|#{line1}|#{line2}|#{line3}"

### Spark Core Stuff ###

#Initiate Spark Core
core = RubySpark::Core.new(SPARK_ID, SPARK_TOKEN)

#Send text to core

core.function("update", payload)

# Figure out whether the backlight should be on or off
now = Time.now.in_time_zone(TZONE)

# Compare them
if now.hour > 23 or now.hour < 7

  # Turn it off at night
  core.function("backlight", "off")

=begin
elsif now.wday == 0

  core.function("backlight", "off")

elsif now.wday == 6

  core.function("backlight", "off")
=end

else

  # Turn it on during the day
  core.function("backlight", "on")

end
