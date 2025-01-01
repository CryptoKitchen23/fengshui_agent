require "test_helper"

class SystemPromptsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get system_prompts_edit_url
    assert_response :success
  end

  test "should get update" do
    get system_prompts_update_url
    assert_response :success
  end
end
