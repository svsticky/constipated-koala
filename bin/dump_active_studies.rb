# Helper script to dump all active Educations in the format accepted by
# update_active_studies.rb. Piping this output to update_active_studies.rb
# should always give no changes.

Education.where(status: :active).each do |edu|
  student_id = edu.member.student_id
  code = edu.study.code
  year = edu.start_date.year

  puts "#{ student_id },#{ code },#{ year }"
end
