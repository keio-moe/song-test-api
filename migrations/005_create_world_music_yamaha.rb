Sequel.migration do
  transaction
  change do
    create_table(:world_music_yamaha_evaluation_entries) do
      primary_key :id
      TrueClass :edited, null: false, default: false
      Integer :song_id, null: false

      Integer :overlap, null: false, default: 0
      Integer :creativity, null: false, default: 0
      Integer :likeness, null: false, default: 0
      Integer :tempo, null: false, default: 0
      Integer :consonance, null: false, default: 0
      Integer :emotion, null: false, default: 0
      Integer :decoration, null: false, default: 0
      Integer :range, null: false, default: 0
      Integer :quality, null: false, default: 0
      Integer :rhythm, null: false, default: 0
      Integer :excitingness, null: false, default: 0
      Integer :groove, null: false, default: 0
      Integer :timbre, null: false, default: 0

      foreign_key :experiment_id, :experiments, null: false, key: [:id]
      unique [:song_id, :experiment_id]
    end

    create_table(:world_music_yamaha_rank_entries) do
      primary_key :id
      TrueClass :edited, null: false, default: false
      Integer :pair_id, null: false

      Integer :option, null: false, default: 0

      foreign_key :experiment_id, :experiments, null: false, key: [:id]
      unique [:pair_id, :experiment_id]
    end
  end
end
