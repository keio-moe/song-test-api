Sequel.migration do
  transaction
  change do
    create_table(:aesthetics_entries) do
      primary_key :id
      TrueClass :edited, null: false, default: false
      Integer :pair_id, null: false
      Integer :pleasant
      Integer :consonant
      Integer :beautiful
      foreign_key :experiment_id, :experiments, null: false, key: [:id]
      unique [:pair_id, :experiment_id]
    end
  end
end
