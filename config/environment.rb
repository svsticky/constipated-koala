# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
ConstipatedKoala::Application.initialize!

# Paperclip settings
Paperclip.options[:command_path] = ['/usr/bin/', '/usr/local/bin/']

# Remove error wrappers
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|

  # todo add class? for red border
  html_tag.html_safe
end
