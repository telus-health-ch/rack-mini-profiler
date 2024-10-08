# frozen_string_literal: true

describe Rack::MiniProfiler::TimerStruct::Page do

  before do
    @page = Rack::MiniProfiler::TimerStruct::Page.new({})
  end

  it 'has an Id' do
    expect(@page[:id]).not_to be_nil
  end

  it 'has a Root' do
    expect(@page[:root]).not_to be_nil
  end

  describe 'to_json' do
    before do
      @json = @page.to_json
      @deserialized = ::JSON.parse(@json)
    end

    it 'has a Started element' do
      expect(@deserialized['started_formatted']).not_to be_nil
      expect(@deserialized['started_formatted']).to match(/Date\(\d{13}\)/)
    end

    it 'has a DurationMilliseconds element' do
      expect(@deserialized['duration_milliseconds']).not_to be_nil
    end
  end

  describe '.from_hash' do
    it 'can re-create Page struct from hash object' do
      page = described_class.new({
        'REQUEST_METHOD' => 'POST',
        'PATH_INFO' => '/some/path',
        'SERVER_NAME' => 'server001'
      })
      from_json_page = described_class.from_hash(JSON.parse(page.to_json))
      expect(page.to_json).to eq(from_json_page.to_json)
    end
  end

  describe '.to_json' do
    it 'does not include the flamegraph itself' do
      page = described_class.new({
        'REQUEST_METHOD' => 'POST',
        'PATH_INFO' => '/some/path',
        'SERVER_NAME' => 'server001',
      })
      page[:has_flamegraph] = true
      page[:flamegraph] = { fake: "data" }
      result = JSON.parse(page.to_json)
      expect(result["flamegraph"]).to eq(nil)
      expect(result["has_flamegraph"]).to eq(true)
    end
  end

  describe '#request_url' do
    let(:env) do
      {
        'rack.url_scheme' => 'https',
        'SERVER_NAME' => 'app.local',
        'SERVER_PORT' => '3000',
        'PATH_INFO' => '/api/v1/hello',
        'QUERY_STRING' => 'foo=bar',
      }
    end

    it 'builds request URL' do
      page = described_class.new(env)
      expect(page.request_url).to eq('https://app.local:3000/api/v1/hello?foo=bar')
    end
  end
end
