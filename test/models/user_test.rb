require "test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users
  test "valid user can authenticate with correct password" do
    user = users(:one)

    assert user.authenticate("Password123!")
  end

  test "user cannot authenticate with incorrect password" do
    user = users(:one)

    assert_not user.authenticate("WrongPassword123!")
  end

  test "email is normalized before saving" do
    user = User.new(
      name: "Test User",
      email_address: "  TEST@EXAMPLE.COM  ",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    assert user.save
    assert_equal "test@example.com", user.email_address
  end

  test "email must be unique" do
    user = User.new(
      name: "Another User",
      email_address: users(:one).email_address,
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    assert_not user.save
    assert_includes user.errors.attribute_names, :email_address
  end

  test "bio cannot exceed 500 characters" do
    user = users(:one)
    user.bio = "a" * 501

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :bio
  end

  test "user has member role by default" do
    user = User.new

    assert_equal "member", user.role
  end
end