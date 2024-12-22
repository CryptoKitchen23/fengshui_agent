require 'test_helper'

class CmcPumpFunServiceTest < ActiveSupport::TestCase
  setup do
    @service = CmcPumpFunService.new
  end

  test 'fetch_coins returns non-null data' do
    result = @service.fetch_coins
    puts result

    assert_not_nil result
    assert_not_empty result
  end
end