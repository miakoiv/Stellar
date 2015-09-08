require 'test_helper'

class CorrespondenceMailerTest < ActionMailer::TestCase
  test "correspondence" do
    mail = CorrespondenceMailer.correspondence
    assert_equal "Correspondence", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
