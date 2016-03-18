class Users::RegistrationsController < Devise::RegistrationsController
  include Devise::Controllers::UrlHelpers

  before_action :configure_permitted_parameters

  # add member to user credentials
  def create
    resource = build_resource(sign_up_params)

    if User.find_by_email(sign_up_params[:email]).present?
      resource = resource_class.send_reset_password_instructions(sign_up_params.slice(:email))
      yield resource if block_given?

      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
      redirect_to :new_user_session
      return
    end

    resource.credentials = Member.find_by_email(sign_up_params[:email])

    if resource.credentials.nil?
      set_flash_message :notice, :'not_found_in_database'

      clean_up_passwords resource
      set_minimum_password_length
      render 'new' and return
    end

    resource_saved = resource.save

    yield resource if block_given?

    if resource_saved
      set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
      expire_data_after_sign_in!
      redirect_to new_user_session_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      render 'new' and return
    end
  end

  # override for adding layout to this view
  def edit
    render :edit, :layout => 'application'
  end

  # make sure the admin is also updated seperatly
  def update
    params = account_update_params
    credentials = params.delete(:credentials)

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, params)

    yield resource if block_given?

    if resource_updated
      flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
      set_flash_message :notice, flash_key

      if resource.admin?
        Admin.find(credentials[:id]).update_attributes(credentials)
      end

      sign_in resource_name, resource, bypass: true
      respond_with resource, location: :edit_registration
    else
      clean_up_passwords resource
      render 'edit', :layout => 'application'
    end
  end

  protected

  # don't allow automatic sign_in for members
  def sign_up(resource_name, resource)
    if resource.admin?
      sign_in(resource_name, resource)
    end
  end

  # allow admin attributes on update user
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit({:credentials => [:id, :type, :first_name, :infix, :last_name, :signature]}, :email, :password, :password_confirmation, :current_password) }
  end

  # Sets minimum password length to show to user
  def set_minimum_password_length
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
  end

end
