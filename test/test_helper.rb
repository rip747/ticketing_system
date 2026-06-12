ENV["RAILS_ENV"] ||= "test"

require "simplecov"

# Set a unique command name per parallel worker so results can be merged
SimpleCov.command_name "Minitest #{ENV.fetch("TEST_ENV_NUMBER", "0")}"

# Allow enough time for parallel workers to merge their results
SimpleCov.merge_timeout 3600

SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/lib/"
  add_filter "/script/"
end

require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"
require "capybara/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    include Capybara::DSL
    include Capybara::Minitest::Assertions

    # Helper to log in as a specific user fixture
    def login_as(user)
      post login_path, params: { email: user.email, password: "password123" }
    end

    # Helper to log in as admin
    def login_as_admin
      login_as(users(:admin))
    end

    # Helper to log in as an agent
    def login_as_agent
      login_as(users(:agent_sarah))
    end

    # Helper to log in as a customer
    def login_as_customer
      login_as(users(:customer_john))
    end

    # Helper to check if a user is logged in
    def logged_in?
      session[:user_id].present?
    end

    teardown do
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
end
