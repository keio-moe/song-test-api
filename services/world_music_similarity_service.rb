class WorldMusicSimilarityService < ExperimentService
  class << self
    PAIRS = (0...20).to_a.combination(2).to_a

    def create(options)
      raise NotFoundError.new('Experiment', 'Evaluation Not Finished') if Experiment.where(
        username: options['username'],
        model: 'WorldMusicEvaluationEntry',
      )&.first.nil?

      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'WorldMusicSimilarityEntry',
        )

        PAIRS.length.times.to_a.shuffle.each do |i|
          WorldMusicSimilarityEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return WorldMusicSimilarityService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'WorldMusicSimilarityEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      WorldMusicSimilarityService.new(exp)
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
      wavs: [
        {
          label: 'A',
          entity: "/static/world_music/#{WorldMusicSimilarityService.singleton_class::PAIRS[entity.pair_id][0]}.mp3",
        },
        {
          label: 'B',
          entity: "/static/world_music/#{WorldMusicSimilarityService.singleton_class::PAIRS[entity.pair_id][1]}.mp3",
        },
      ],
    }
  end

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry Not Existed') if entry.nil?
    entry.similarity = options['similarity']
    entry.likeness = options['likeness']
    entry.edited = true
    entry.save
    nil
  end

  def destroy
    @entity.entries.delete
    @entity.delete
  end
end
