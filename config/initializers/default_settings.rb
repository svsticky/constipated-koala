# year doesn't matter as long as it is in the past, cronjob creates new date incrementing exactly one year
Settings.defaults[:begin_study_year] = Date.parse( '2009-09-01' )

Settings.defaults[:mongoose_ideal_costs] = 0.29
Settings.defaults[:liquor_time] = '16:00'

Settings.defaults[:intro_membership] = [1]
Settings.defaults[:intro_activities] = []

Settings.defaults[:additional_committee_positions] = ['fotograaf']
Settings.defaults[:additional_moot_positions] = []
