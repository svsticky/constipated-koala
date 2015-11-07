object @member
attributes :id, :first_name, :infix, :last_name

# attributes accessible if an user is authenticated or an app has client_credentials and default member-read
if Authorization._user.present? || Authorization._client.include?('member-read')
  child :educations do
    node :study do |education|
      education.study.code
    end
    node :active do |education|
      education.status == 'active'
    end
  end
end

# attributes if the member itself is authenticated
if Authorization._member == @member
  attributes :birth_date, :gender, :student_id, :join_date
  attributes :address, :house_number, :postal_code, :city
  attributes :phone_number, :email

  child :educations do
    node :study do |education|
      education.study.code
    end

    attributes :id, :status
  end
end
