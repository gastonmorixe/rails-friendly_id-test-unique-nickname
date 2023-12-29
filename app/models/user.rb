class User < ApplicationRecord
  extend FriendlyId
  # friendly_id :nickname, use: :slugged 
  # validates_format_of :nickname, :with => /\A[a-z0-9]+\z/i
  friendly_id :slug_candidates, use: :slugged

  def slug_candidates
    [
      # :first_name,
      # :first_name, :last_name,
      # :custom_nickname,
      # -> { custom_nickname_with_random_chars },
      # -> { generate_custom_nickname_smart },
      -> { generate_custom_nickname_smart_two }
    ]
  end

  def custom_nickname
    "#{first_name}#{last_name.chars.first}"
  end

  def random_string
    # SecureRandom.alphanumeric(5)
    "-FIXED-000"
  end

  def custom_nickname_with_random_chars
    "#{custom_nickname}#{random_string}"
  end

  def generate_custom_nickname_smart
    base_nickname = sanitize_name(first_name) + sanitize_name(last_name).chars.first.to_s
    nickname_candidate = base_nickname.dup
    retry_count = 0
    max_retries = 10  # Set a maximum number of retries to avoid infinite loops

    Rails.logger.debug("#generate_custom_nickname_smart nickname_candidate: #{nickname_candidate} - retry_count: #{retry_count}")
    while User.exists?(slug: nickname_candidate) && retry_count < max_retries
      nickname_candidate = base_nickname + SecureRandom.alphanumeric(retry_count + 1)
      retry_count += 1
      Rails.logger.debug(">> #generate_custom_nickname_smart nickname_candidate: #{nickname_candidate} - retry_count: #{retry_count}")
    end

    nickname_candidate
  end

  def generate_custom_nickname_smart_two
    base_nickname = sanitize_name(first_name) + sanitize_name(last_name).chars.first.to_s
    retries_per_character = 5  # Number of retries with the same number of characters
    current_char_count = 1     # Start with one additional character

    loop do
      retries_per_character.times do
        nickname_candidate = base_nickname + SecureRandom.alphanumeric(current_char_count)
        return nickname_candidate unless User.exists?(slug: nickname_candidate)
      end
      current_char_count += 1  # Increase the number of random characters after retries
    end
  end

  private

  def sanitize_name(name)
    name.to_s.strip
  end
end
