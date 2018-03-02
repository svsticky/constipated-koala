# Update active members from a CSV-file containing the data provided by ICT-Beta.
#
# This script takes a CSV file containing the following rows:
#  - Student ID,
#  - Study type
#  - Start year
#
# It will then iterate over each known Member, updating the status of their study:
#  - If the Member's student ID DOES appear in the file:
#     An Education is retrieved or created for the specified Member and Study.
#     If no Education existed (yet), the start date is set to the current date
#     (as we cannot assume a start date from the given year).
#
#     Lastly, the Education is set to active and saved.
#
# - If the Member's student ID DOES NOT appear in the file:
#     All active Educations for the Member are retrieved, set to inactive, and saved.
require 'csv'
require 'set'

$log = Logger.new(STDOUT)

def read_input
  # Input may be given on STDIN or as a single filename. Ruby automagically
  # tosses this in the ARGF array, which behaves like a file.
  $log.info 'Reading input...'
  result = {}

  CSV(ARGF) do |csvf|
    csvf.each do |row|
      result[row[0]] = [row[1], row[2]]
    end
  end

  $log.info "Received data on #{result.length} active students."

  result
end

def leguiddit(studydata)
  activated = 0
  deactivated = 0
  noop = 0

  Member.each do |m|
    enrollment = studydata[m.student_id]

    if m.enrolled_in_study? and !enrollment
      $log.info("Deactivating #{m.student_id}")

      edus = Education.where(member: m, status: :active)
      edus.each do |edu|
        edu.status = :graduated # XXX Incorrect data but no better alternative
        edu.end_date = Date.today
        edu.save!
      end

      deactivated += 1

    elsif enrollment and !m.enrolled_in_study?
      $log.info("Activating #{m.student_id}")
      study = Study.find(code: enrollment[0])

      edu = Education.find_or_initialize_by(
        member: m,
        study: study
      )

      edu.start_date ||= Date.today # Update if not present
      edu.status = :active

      edu.save!

      activated += 1

    else
      noop += 1
    end

  end

  $log.info <<~LOG
    --- SUMMARY ---
    Activated:   #{activated}
    Deactivated: #{deactivated}
    Unchanged:   #{noop}
  LOG
end

def dryrun(studydata)
  activated = 0
  deactivated = 0
  noop = 0

  Member.all.each do |m|
    enrollment = studydata[m.student_id]

    if m.enrolled_in_study? and !enrollment
      $log.info("Would deactivate #{m.student_id}")

      deactivated += 1

    elsif enrollment and !m.enrolled_in_study?
      $log.info("Would activate #{m.student_id}")

      activated += 1
    else
      noop += 1
    end

  end

  $log.info <<~LOG
    --- SUMMARY ---
    Would be activated:   #{activated}
    Would be deactivated: #{deactivated}
    Would be unchanged:   #{noop}
  LOG
end

def main
  indata = read_input
  dryrun indata
end

main
