# Load the Rails application.
require_relative 'application'

# Paperclip settings
Paperclip.options[:command_path] = ['/usr/bin/', '/usr/local/bin/']

# Remove error wrappers, TODO still required?
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /<(input|label|textarea|select)/
    html_field = Nokogiri::HTML::DocumentFragment.parse(html_tag)
    html_field.children.add_class 'invalid'

    %{#{html_field.to_html}}.html_safe
  else
    html_tag.html_safe
  end
end

# Initialize the Rails application.
ConstipatedKoala::Application.initialize!
