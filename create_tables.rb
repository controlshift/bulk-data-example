#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'byebug'

def normalize_types(type)
  if %w(hstore json jsonb text).include?(type)
    'CHARACTER VARYING(max)'
  else
    type
  end

end


uri = URI('https://demo.controlshiftlabs.com/api/bulk_data/schema.json')
json = Net::HTTP.get(uri)
tables = JSON.parse(json)['tables']

tables.each do |table|
  name = table['table']['name']
  columns = table['table']['columns']
  column_fields = columns.collect{|col, attrs| "\"#{col}\" #{normalize_types(attrs["sql_type"])}" }.join(', ')
  puts "DROP TABLE IF EXISTS #{name};"
  puts "CREATE TABLE #{name} (#{column_fields});"
end


