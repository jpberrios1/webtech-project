
require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  fixtures :users

  setup do
    @user = users(:one)
  end

  test "user can sign up and gets authenticated" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          name: "New User",
          email_address: "new.user@example.com",
          phone: "912345678",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
    assert_equal "New User", User.find_by(email_address: "new.user@example.com").name
  end

  test "user can log in with correct credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "Password123!"
    }

    assert_redirected_to root_url

    get profile_path
    assert_response :success
  end

  test "user cannot log in with incorrect credentials" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "WrongPassword123!"
    }

    assert_redirected_to new_session_path
    get profile_path
    assert_redirected_to new_session_path
  end

  test "user can log out and loses access to private pages" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "Password123!"
    }

    delete session_path

    assert_redirected_to new_session_path

    get profile_path
    assert_redirected_to new_session_path
  end

  test "user can update their profile" do
    post session_path, params: {
      email_address: @user.email_address,
      password: "Password123!"
    }

    patch profile_path, params: {
      user: {
        name: "Updated Name",
        email_address: "updated@example.com",
        phone: "998877665",
        bio: "My updated biography"
      }
    }

    assert_redirected_to profile_path

    @user.reload
    assert_equal "Updated Name", @user.name
    assert_equal "updated@example.com", @user.email_address
    assert_equal "998877665", @user.phone
    assert_equal "My updated biography", @user.bio
  end

  test "password reset request enqueues an email" do
    assert_enqueued_emails 1 do
      post passwords_path, params: {
        email_address: @user.email_address
      }
    end

    assert_redirected_to new_session_path
  end

  test "password reset email contains the correct recipient and subject" do
    perform_enqueued_jobs do
      post passwords_path, params: {
        email_address: @user.email_address
      }
    end

    email = ActionMailer::Base.deliveries.last

    assert_not_nil email
    assert_equal [ @user.email_address ], email.to
    assert_equal "Reset your Roomies password", email.subject
    assert_match "Reset your Roomies password", email.body.encoded
    assert_match "/passwords/", email.body.encoded
  end

  test "password can be reset using a valid token" do
    token = @user.generate_token_for(:password_reset)

    patch password_path(token), params: {
      password: "NewPassword123!",
      password_confirmation: "NewPassword123!"
    }

    assert_redirected_to new_session_path

    @user.reload
    assert @user.authenticate("NewPassword123!")
    assert_not @user.authenticate("Password123!")
  end

  test "password reset token expires after 15 minutes" do
    token = @user.generate_token_for(:password_reset)

    travel 16.minutes

    get edit_password_path(token)

    assert_redirected_to new_password_path
  end
end
