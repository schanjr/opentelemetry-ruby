# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'manticore'

Bundler.require

OpenTelemetry::SDK.configure do |c|
  c.use 'OpenTelemetry::Instrumentation::Manticore'
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(
      OpenTelemetry::SDK::Trace::Export::ConsoleSpanExporter.new
    )
  )
  c.service_name = 'demo example'
end

# sync call
resp = Manticore.get('https://example.com?query=1')
puts "*" * 20, "sync call"
puts "response code: #{resp.code}"

# async call
client = Manticore::Client.new
async_resp1 = client.parallel.get("http://www.example1.com")
async_resp1.on_complete do |r|
  puts "*" * 20, "parallel call #{r.request.uri.to_s }"
  puts "response code: #{r.code}"
end

async_resp2 = client.parallel.get("http://www.example2.com")
async_resp2.on_complete do |r|
  puts "*" * 20, "parallel call #{r.request.uri.to_s }"
  puts "response code: #{r.code}"
end

client.execute!