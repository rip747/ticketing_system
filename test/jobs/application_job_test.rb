require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  test "application job base class exists" do
    assert_kind_of Class, ApplicationJob
    assert_equal ActiveJob::Base, ApplicationJob.superclass
  end
end
