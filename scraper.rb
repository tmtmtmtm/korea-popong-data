#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'csv'
require 'json'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def json_from(url)
  JSON.parse(open(url).read, symbolize_names: true)
end

@POPONG_API = 'http://api.popong.com/v0.1/person/%s?api_key=test'

file = 'https://raw.githubusercontent.com/teampopong/data-for-rnd/master/assembly.csv'
raw = open(file).read

csv = CSV.parse(raw, headers: true, header_converters: :symbol)
csv.each do |row|
  json = json_from(@POPONG_API % row[:person_id]) rescue {}
  warn "%s vs %s".red % [row[:name_en], json[:name_en]] unless row[:name_en] == json[:name_en]

  data = { 
    id: row[:person_id],
    identifier__popong: row[:person_id],
    name: row[:name_en].strip,
    name__ko: row[:name],
    name__cn: row[:name__cn],
    birth_date: row[:birth],
    party: row[:party],
    area: row[:district],
    phone: row[:off_phone],
    homepage: row[:homepage],
    email: row[:email],
    photo: 'http://www.assembly.go.kr/photo/%s.jpg)' % row[:photo_id],
    term: 19,
    source: "github.com/teampopong/data-for-rnd",

    wikipedia: json[:wiki],
    twitter: json[:twitter],
    facebook: json[:facebook],
  }


  # puts data
  ScraperWiki.save_sqlite([:id, :term], data)
end


