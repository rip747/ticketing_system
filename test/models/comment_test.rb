require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    comment = Comment.new(
      body: "This is a comment",
      user: users(:agent_sarah),
      ticket: tickets(:laptop_issue)
    )
    assert comment.valid?
  end

  test "should require body" do
    comment = Comment.new(user: users(:agent_sarah), ticket: tickets(:laptop_issue))
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "should belong to user" do
    comment = comments(:comment_one)
    assert_respond_to comment, :user
    assert_equal users(:agent_sarah), comment.user
  end

  test "should belong to ticket" do
    comment = comments(:comment_one)
    assert_respond_to comment, :ticket
    assert_equal tickets(:vpn_issue), comment.ticket
  end

  test "scope recent orders by created_at asc" do
    comments = tickets(:vpn_issue).comments.recent
    assert_equal Comment.where(ticket: tickets(:vpn_issue)).order(created_at: :asc).pluck(:id),
                 comments.pluck(:id)
  end
end
