require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "should require login to create comment" do
    post ticket_comments_path(tickets(:vpn_issue)), params: { comment: { body: "Test" } }
    assert_redirected_to login_path
  end

  test "should create comment" do
    login_as_customer
    assert_difference("Comment.count") do
      post ticket_comments_path(tickets(:vpn_issue)), params: { comment: { body: "New comment" } }
    end
    assert_equal users(:customer_john), Comment.last.user
    assert_equal tickets(:vpn_issue), Comment.last.ticket
  end

  test "should not create empty comment" do
    login_as_customer
    assert_no_difference("Comment.count") do
      post ticket_comments_path(tickets(:vpn_issue)), params: { comment: { body: "" } }
    end
  end

  test "should require login to destroy comment" do
    ticket = comments(:comment_one).ticket
    delete ticket_comment_path(ticket, comments(:comment_one))
    assert_redirected_to login_path
  end

  test "should destroy own comment" do
    login_as_customer
    comment = comments(:comment_two) # owned by customer_john
    ticket = comment.ticket
    assert_difference("Comment.count", -1) do
      delete ticket_comment_path(ticket, comment)
    end
  end

  test "should not destroy another user's comment as customer" do
    login_as_customer
    comment = comments(:comment_one) # owned by agent_sarah
    ticket = comment.ticket
    assert_no_difference("Comment.count") do
      delete ticket_comment_path(ticket, comment)
    end
  end

  test "should destroy any comment as admin" do
    login_as_admin
    comment = comments(:comment_one) # owned by agent_sarah
    ticket = comment.ticket
    assert_difference("Comment.count", -1) do
      delete ticket_comment_path(ticket, comment)
    end
  end
end
