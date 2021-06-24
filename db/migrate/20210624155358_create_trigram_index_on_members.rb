class CreateTrigramIndexOnMembers < ActiveRecord::Migration[6.0]
  # An index can be created concurrently only outside of a transaction.
  self.disable_ddl_transaction!

  def up
    # Don't try to merge these statements, a transaction will be created (wtf rails)
    execute "CREATE INDEX CONCURRENTLY member_first_names ON members USING GIN(first_name gin_trgm_ops);"
    execute "CREATE INDEX CONCURRENTLY member_last_names ON members USING GIN(last_name gin_trgm_ops);"
  end

  def down
    execute "DROP INDEX member_first_names;"
    execute "DROP INDEX member_last_names;"
  end
end
