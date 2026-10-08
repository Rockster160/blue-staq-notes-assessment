module AuthHelpers
  def json = response.parsed_body

  def sign_in(user)
    post "/session", params: { email: user.email, password: user.test_password }, as: :json
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
