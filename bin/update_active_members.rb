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
require 'optparse'
require 'set'

# Global variables
# rubocop:disable Style/GlobalVars
$log = Logger.new(STDOUT)

$study_cache = Study.all.map { |s| [s.code, s] }.to_h
$studies     = $study_cache.keys

def read_input
  # Input may be given on STDIN or as a single filename. Ruby automagically
  # collects this in the ARGF array, which behaves like a file.
  #
  # Also asserts that the data makes sense:
  #  - Student ID should be exactly 7 characters
  #  - Study code should be four characters and known to the DB,
  #  - Start year should be four digits.
  #
  # Returns a Hash linking student ID to a list of [code, year] pairs.
  # Note that this list will also exist for unknown students, check if the list
  # contains anything instead of checking if the list exists!
  $log.info 'Reading input...'
  result = Hash.new { |h, k| h[k] = [] }

  CSV(ARGF) do |csvf|
    csvf.each do |row|
      student_id = row[0]
      study_code = row[1]
      start_year = row[2]

      unless student_id.length == 7
        $log.warning "Skipping entry #{ student_id }: invalid length"
        next
      end

      unless $studies.include?(study_code)
        $log.warning "Skipping entry #{ student_id }: invalid code #{ study_code }"
        next
      end

      unless start_year.length == 4
        $log.warning "Skipping entry #{ student_id }: invalid year #{ start_year }"
        next
      end

      result[student_id] << [study_code, start_year]
    end
  end

  $log.info "Received data on #{ result.length } active students."

  result
end

def activate(member, study_code)
  edu = Education.find_or_initialize_by(
    member: member,
    study: $studies[study_code]
  )

  edu.start_date ||= Date.today # Only changed if not present
  edu.status = :active

  edu.save!
end

def deactivate(member, study_code)
  edu = Education.find_by(
    member: member,
    study: $studies[study_code]
  )

  edu.status = :inactive
  edu.end_date = Date.today

  edu.save!
end

def leguiddit(studydata)
  activated = 0
  deactivated = 0
  noop = 0
  switched = 0

  Member.each do |m|
    # The script expects the following situations:
    #  - Student was inactive, and still is (no-op)
    #  - Student was active, and still is (no-op)
    #  - Student was inactive, and is now active (create or re-activate Education)
    #  - Student was active, and is now inactive (de-activate Education(s))
    #  - Student was active in one Study, and now does another Study
    #    (de-activate original Education, create or activate new Education)

    enrollments = studydata[m.student_id]
    data_enrolled = enrollments.any?
    active_codes = enrollments.pluck(0).to_set

    if m.enrolled_in_study? && !data_enrolled # Was active, is no longer: deactivate all Educations
      $log.info("Deactivating #{ m.student_id }")

      # Special case for not using `deactivate`: we nuke all active Educations of this Member, just to be sure.
      edus = Education.where(member: m, status: :active)
      edus.each do |edu|
        edu.status = :inactive
        edu.end_date = Date.today
        edu.save!
      end

      deactivated += 1

    elsif data_enrolled && !m.enrolled_in_study? # Was inactive, now active: create or activate Education(s)
      $log.info("Activating #{ m.student_id }")

      enrollments.each do |enrollment|
        activate(m, enrollment[0])
      end

      activated += 1

    elsif data_enrolled && m.enrolled_in_study? # Check that the correct set of studies is active
      active_db_studies =
        m
        .educations
        .where(status: :active)
        .joins(:study)
        .pluck(:code)
        .to_set

      if active_db_studies != active_codes
        to_deactivate = active_db_studies - active_codes
        # The set of studies that this person stopped doing is the set of
        # active studies in the database, minus the set of active studies given
        # in the input.

        to_activate = active_codes - active_db_studies
        # The set of studies that this person started doing is the set of
        # active studies in the input, minus the set of active studies known in
        # the database.
        $log.info "Switching #{ m.student_id } (-: #{ to_deactivate.to_a.join(', ') }, +: #{ to_activate.to_a.join(', ') })"

        to_deactivate.each do |code|
          deactivate(m, code)
        end

        to_activate.each do |code|
          activate(m, code)
        end

        switched += 1
      else
        noop += 1
      end

    else
      noop += 1
    end
  end

  $log.info <<~LOG
    --- SUMMARY ---
    Activated:   #{ activated }
    Deactivated: #{ deactivated }
    Switched:    #{ switched }
    Unchanged:   #{ noop }
  LOG
end

def dryrun(studydata)
  activated = 0
  deactivated = 0
  noop = 0
  switched = 0

  Member.all.each do |m|
    enrollments = studydata[m.student_id]
    data_enrolled = enrollments.any?
    active_codes = enrollments.pluck(0).to_set

    if m.enrolled_in_study? && !data_enrolled
      $log.info("Would deactivate #{ m.student_id }")

      deactivated += 1

    elsif data_enrolled && !m.enrolled_in_study?
      $log.info("Would activate #{ m.student_id }")

      activated += 1
    elsif data_enrolled && m.enrolled_in_study?
      active_db_studies =
        m
        .educations
        .where(status: :active)
        .joins(:study)
        .pluck(:code)
        .to_set

      if active_db_studies != active_codes
        to_deactivate = active_db_studies - active_codes
        to_activate = active_codes - active_db_studies
        $log.info "Would switch #{ m.student_id } (-: #{ to_deactivate.to_a.join(', ') }, +: #{ to_activate.to_a.join(', ') })"
        switched += 1
      else
        noop += 1
      end
    else
      noop += 1
    end
  end

  $log.info <<~LOG
    --- SUMMARY ---
    Would be activated:   #{ activated }
    Would be deactivated: #{ deactivated }
    Would be switched:    #{ switched }
    Would be unchanged:   #{ noop }
  LOG
end

def main
  mode = :real

  OptionParser.new do |opts|
    opts.banner =
      'Usage: rails runner bin/update_active_members.rb [options] [infile]'

    opts.on('-n', '--not-really', 'Dry run: list only the changes that would be made') do
      mode = :dryrun
    end

    opts.on('-h', '--help', 'Print this help') do
      puts opts
      exit
    end
  end.parse!

  # `parse!` removes all option flags from ARGV, leaving only input filenames
  # (if any) for use by ARGF in `read_input`.

  indata = read_input

  if mode == :dryrun
    dryrun indata
  else
    leguiddit indata
  end
end

main
