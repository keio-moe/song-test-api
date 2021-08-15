Sequel.migration do
  transaction
  change do
    create_table(:indian_music_evaluation_entries) do
      primary_key :id
      TrueClass :edited, null: false, default: false
      Integer :song_id, null: false

      Integer :ornamentation, null: false, default: 0
      Integer :grooviness, null: false, default: 0
      Integer :familiarity, null: false, default: 0
      Integer :liking, null: false, default: 0
      Integer :consonance, null: false, default: 0
      Integer :valence, null: false, default: 0
      Integer :excitement, null: false, default: 0
      Integer :sound_quality, null: false, default: 0
      Integer :tempo, null: false, default: 0
      Integer :rhythmic_regularity, null: false, default: 0
      Integer :vocal_range, null: false, default: 0
      Integer :vocal_tension, null: false, default: 0
      Integer :vocal_texture, null: false, default: 0
      Integer :instrument_vocal_overlap, null: false, default: 0
      Integer :instrument_overlap, null: false, default: 0
      Integer :instrument_tone_blend, null: false, default: 0
      Integer :instrument_rhythm_blend, null: false, default: 0

      foreign_key :experiment_id, :experiments, null: false, key: [:id]
      unique [:song_id, :experiment_id]
    end
  end
end
  