class App < Sinatra::Application
  get '/hiring/createbodmeta' do

    @response = AtlasConnector.new.call(:create_bod_meta, body: {
      "bod_id" => 'BATCH_5e991b88-efe6-49f2-8f5a-814359457472',
      gcc: 'ZZA',
      lcc: 'VN002',
      event: 'batch_file',
      "create_date_time" => '2014-12-05T09:44:10+00:00',
      "event_time_stamp" => '2014-12-05T09:44:10.000+00:00',
      system: '1001',
      "payroll_exchange_id" => '199511190',
      event: 'hiring',
      system: '1001'
    })

  end

end
