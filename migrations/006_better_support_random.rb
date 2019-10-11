Sequel.migration do
  transaction
  change do
    add_column :copyright_full_entries, :song_a, Integer, null: true
    add_column :copyright_full_entries, :song_b, Integer, null: true
  end
end
