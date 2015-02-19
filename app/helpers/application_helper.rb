module ApplicationHelper
  # Partial helpers that do the ugly work of defining partial locals.
  #
  # Instead of having to write this:
  #
  # render partial: 'nav_item', locals: { url: '/', name: 'Home', color:
  #   'danger', icon: 'desktop'}
  #
  # You can write the following:
  #
  # nav_item name: 'home', icon: 'desktop', color: 'danger'
  #
  #   block_to_partial('shared/sidebar_module'

  # nav_item renders a navigation item
  #
  # It takes an options hash with the following items:
  #   - name:  Name to display in link, should be lowercase
  #   - icon:  FA icon to use as item background
  #   - color: CSS class to use for the bg styling
  #
  # You can also give it an optional block that you can render subitems in.
  #
  # Subitems can be put in the block. These render subitems and take a name and
  # a url.
  def nav_item(options = {}, &block)
    if block_given?
      options.merge!(:body => capture(&block))
    end
    render partial: 'nav_item', locals: options
  end
  def nav_subitem(options = {}, &block)
    if block_given?
      options.merge!(:body => capture(&block))
    end
    render partial: 'nav_subitem', locals: options
  end
end
