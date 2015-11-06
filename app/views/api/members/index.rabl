collection @members

attributes :id, :first_name, :infix, :last_name

# Add contact information for yourself
if Authorization._member == @member
  attributes :phone_number, :email
end
