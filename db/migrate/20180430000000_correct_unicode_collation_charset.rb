class CorrectUnicodeCollationCharset < ActiveRecord::Migration[5.1]
  # Based on https://gist.github.com/amuntasim/f3b12f20a30e9a9f3fb0
  def up
    connection = ActiveRecord::Base.connection

    return unless connection.adapter_name == 'Mysql2'

    execute "ALTER DATABASE `#{ connection.current_database }` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

    excluded = [
      'ar_internal_metadata', # Seems to be 'do not touch'
    ]

    connection.tables.each do |table|
      unless excluded.include?(table)
        execute "ALTER TABLE `#{ table }` ROW_FORMAT=DYNAMIC"
        execute "ALTER TABLE `#{ table }` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
      end
    end
  end

  def down
    # We're not reversing this, as it'll crash if you've added emoji after the migration.
  end
end
