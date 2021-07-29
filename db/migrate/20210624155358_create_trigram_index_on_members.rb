class CreateTrigramIndexOnMembers < ActiveRecord::Migration[6.0]
  # An index can be created concurrently only outside of a transaction.
  self.disable_ddl_transaction!

  def up
    # Don't try to merge these statements, a transaction will be created and the statements will fail.
    # This behaviour is undocumented.
    execute "CREATE INDEX CONCURRENTLY member_first_names ON members USING GIN(first_name gin_trgm_ops);"
    execute "CREATE INDEX CONCURRENTLY member_last_names ON members USING GIN(last_name gin_trgm_ops);"
    execute "CREATE INDEX CONCURRENTLY member_email ON members USING GIN(phone_number gin_trgm_ops);"
    execute "CREATE INDEX CONCURRENTLY member_phone_number ON members USING GIN(phone_number gin_trgm_ops);"
    execute "CREATE INDEX CONCURRENTLY member_student_id ON members USING GIN(student_id gin_trgm_ops);"
  end

  def down
    execute "DROP INDEX member_first_names;"
    execute "DROP INDEX member_last_names;"
    execute "DROP INDEX member_email;"
    execute "DROP INDEX member_phone_number;"
    execute "DROP INDEX member_student_id;"
  end
end
