Sequel.migration do
  transaction
  change do
    create_table(:copyright_new_workshop_entries) do
      primary_key :id
      TrueClass :edited, null: false, default: false
      Integer :pair_id, null: false
      Integer :similarity, null: false, default: 0
      TrueClass :infringe, null: false, default: false
      foreign_key :experiment_id, :experiments, null: false, key: [:id]
      unique [:pair_id, :experiment_id]
    end
  end
end
