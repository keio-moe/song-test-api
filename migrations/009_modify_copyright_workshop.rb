Sequel.migration do
  transaction
  change do
    add_column :copyright_new_workshop_entries, :song_a, Integer, null: true
    add_column :copyright_new_workshop_entries, :song_b, Integer, null: true
  end
end
