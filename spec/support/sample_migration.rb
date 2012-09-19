require 'active_record'

class SampleMigration < ActiveRecord::Migration
  def self.run
    create_table :sample_models do |t|
      t.integer :flags
      t.timestamps
    end
  end
end