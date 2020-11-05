# Usage: rails runner bin/test_all_mails.rb

return unless Rails.env.development?

Mailings::Checkout.confirmation_instructions(CheckoutCard.first, 'placeholder')

Mailings::Devise.confirmation_instructions(User.second, 'placeholder')

Mailings::Devise.activation_instructions(User.second, 'placeholder')

Mailings::Devise.reset_password_instructions(User.second, 'placeholder')

Mailings::Participants.enrolled(Participant.first)
