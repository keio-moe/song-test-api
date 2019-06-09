class WorldMusicEvaluationService < ExperimentService
  class << self
    SONG_SIZE = 20

    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'WorldMusicEvaluationEntry',
        )

        SONG_SIZE.times.to_a.shuffle.each do |i|
          WorldMusicEvaluationEntry.create(
            experiment: exp,
            song_id: i,
          )
        end

        return WorldMusicEvaluationService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'WorldMusicEvaluationEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      WorldMusicEvaluationService.new(exp)
    end

    def export
      raise NotImplementedError.new
    end
  end

  def initialize(entity)
    @entity = entity
  end

  def next
    entity = @entity.entries.where(edited: false).order(:id).first
    raise NotFoundError.new('Entity', 'Experiment Finished') if entity.nil?
    {
      id: entity.id,
      progress: @entity.entries.where(edited: true).count.to_f / @entity.entries.count,
      wavs: [{
        label: 'Sample',
        entity: "/static/world_music/#{entity.song_id}.mp3",
      }],
    }
  end

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry Not Existed') if entry.nil?
    entry.overlap = options['overlap']
    entry.creativity = options['creativity']
    entry.likeness = options['likeness']
    entry.tempo = options['tempo']
    entry.consonance = options['consonance']
    entry.emotion = options['emotion']
    entry.decoration = options['decoration']
    entry.range = options['range']
    entry.quality = options['quality']
    entry.rhythm = options['rhythm']
    entry.excitingness = options['excitingness']
    entry.groove = options['groove']
    entry.timbre = options['timbre']
    entry.edited = true
    entry.save
    nil
  end

  def destroy
    @entity.entries.delete
    @entity.delete
  end
end
