require File.join(File.dirname(__FILE__), '../../test_helper')

describe 'host subscription unregister' do

  before do
    @cmd = %w(host subscription unregister)
  end
  let(:params) { ['--host-id=3'] }

  it "lists content counts" do

    ex = api_expects(:host_subscription, :destroy,'Get sync info') do |par|
      par['host_id'] == '3'
    end
    ex.returns({})


    expected_result = success_result(
      "Parameter [A] deleted\n"
    )

    result = run_cmd(@cmd + params)
    assert_cmd(expected_result, result)
  end

  it "resolves id from name" do
    params = ['--host=host1']

    api_expects(:host_subscription, :sync_status, 'Get sync info') do |par|
      par['host_id'] == '3'
    end
    expect_host_search('host1', '3')

    run_cmd(@cmd + params)
  end
end
