class IndianMusicEvaluationService < ExperimentService
  class << self
    SONG_SIZE = 10

    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'IndianMusicEvaluationEntry',
        )

        SONG_SIZE.times.to_a.shuffle.each do |i|
          IndianMusicEvaluationEntry.create(
            experiment: exp,
            song_id: i,
          )
        end

        return IndianMusicEvaluationService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'IndianMusicEvaluationEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No such experiment exists') if exp.nil?
      IndianMusicEvaluationService.new(exp)
    end

    def export
      Experiment.where(
        model: 'IndianMusicEvaluationEntry',
      ).map do |exp|
        res = exp.entries.order(:song_id).map do |pair|
          {
            id: pair.song_id,
            ornamentation: pair.ornamentation,
            grooviness: pair.grooviness,
            familiarity: pair.familiarity,
            liking: pair.liking,
            consonance: pair.consonance,
            valence: pair.valence,
            excitement: pair.excitement,
            sound_quality: pair.sound_quality,
            tempo: pair.tempo,
            rhythmic_regularity: pair.rhythmic_regularity,
            vocal_range: pair.vocal_range,
            vocal_tension: pair.vocal_tension,
            vocal_texture: pair.vocal_texture,
            instrument_vocal_overlap: pair.instrument_vocal_overlap,
            instrument_overlap: pair.instrument_overlap,
            instrument_tone_blend: pair.instrument_tone_blend,
            instrument_rhythm_blend: pair.instrument_rhythm_blend,
            edited: pair.edited,
          }
        end
        {
          username: exp.username,
          matrix: res,
        }
      end
    end
  end

  def initialize(entity)
    @entity = entity
  end

  def offset
    cat = @entity.username[-1].to_i
    raise NotFoundError.new('Entity', 'No Such Category') unless (0..4).include?(cat) # 4 Groups
    @entity.username[-1].to_i * 6
  end

  def next
    entity = @entity.entries.where(edited: false).order(:id).first
    raise NotFoundError.new('Entity', 'Experiment Finished') if entity.nil?
     
    res = {
      id: entity.id,
      progress: @entity.entries.where(edited: true).count.to_f / @entity.entries.count,
      wavs: []
    }

    if (0..4).include?(entity.id)
      res[:wavs] << {
        label: 'Sample',
        entity: "/static/indian_music/sample#{entity.song_id}.mp3",
      }
    else 
      res[:wavs] << {
        label: 'Sample',
        entity: "/static/indian_music/#{entity.song_id + offset}.mp3",
      }
    end
    res
  end
  

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry does not exist') if entry.nil?
    entry.ornamentation = options['ornamentation']
    entry.grooviness = options['grooviness']
    entry.familiarity = options['familiarity']
    entry.liking = options['liking']
    entry.consonance = options['consonance']
    entry.valence = options['valence']
    entry.excitement = options['excitement']
    entry.sound_quality = options['sound_quality']
    entry.tempo = options['tempo']
    entry.rhythmic_regularity = options['rhythmic_regularity']
    entry.vocal_range = options['vocal_range']
    entry.vocal_tension = options['vocal_tension']
    entry.vocal_texture = options['vocal_texture']
    entry.instrument_vocal_overlap = options['instrument_vocal_overlap']
    entry.instrument_overlap = options['instrument_overlap']
    entry.instrument_tone_blend = options['instrument_tone_blend']
    entry.instrument_rhythm_blend = options['instrument_rhythm_blend']
    entry.edited = true
    entry.save
    nil
  end

  def destroy
    @entity.entries.delete
    @entity.delete
  end
end
