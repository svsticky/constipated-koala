object @member
attributes :id, :first_name, :infix, :last_name

# attributes accessible if an user is authenticated
if Authorization._user.present?
  child :educations do
    node :study do |education|
      education.study.code
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
