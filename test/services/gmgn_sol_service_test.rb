require 'test_helper'

class GmgnSolServiceTest < ActiveSupport::TestCase
  def setup
    @service = GmgnSolService.new
  end

  test "should fetch non-null recommendations with filtered fields" do
    fields = [:created_timestamp, :name]
    recommendations = @service.fetch_recommendations(fields: fields)
    assert_not_nil recommendations, "Recommendations should not be nil"
    assert recommendations.is_a?(Array), "Recommendations should be an array"
    assert_not_empty recommendations, "Recommendations should not be empty"
    recommendations.each do |rec|
      fields.each do |field|
        assert rec.key?(field), "Recommendation should have #{field}"
      end
    end
  end
end