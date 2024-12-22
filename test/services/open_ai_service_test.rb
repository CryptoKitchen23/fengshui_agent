require 'test_helper'

class OpenAIServiceTest < ActiveSupport::TestCase
  setup do
    @service = OpenAIService.new
  end

  test 'Open AI system prompt returns non-null data' do
    puts @service.instance_variable_get(:@system_prompt)
    assert_not_nil @service.instance_variable_get(:@system_prompt)[:content]
  end
end