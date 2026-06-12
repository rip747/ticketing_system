require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "application mailer base class exists" do
    assert_kind_of Class, ApplicationMailer
    assert_equal ActionMailer::Base, ApplicationMailer.superclass
    assert_equal "from@example.com", ApplicationMailer.default[:from]
  end
end
