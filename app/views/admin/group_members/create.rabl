object @member
attributes :id

glue @member.member do
  attributes :first_name, :infix, :last_name
end
