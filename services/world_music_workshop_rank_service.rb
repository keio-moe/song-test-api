class WorldMusicWorkshopRankService < ExperimentService
  class << self
    SONGS = 5
    PAIRS = (0...SONGS).to_a.combination(3).to_a

    def create(options)
      raise NotFoundError.new('Experiment', 'Evaluation Not Finished') if Experiment.where(
        username: options['username'],
        model: 'WorldMusicWorkshopRankEntry',
      )&.first.nil?

      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'WorldMusicWorkshopRankEntry',
        )

        PAIRS.length.times.to_a.shuffle.each do |i|
          WorldMusicWorkshopRankEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return WorldMusicWorkshopRankService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'WorldMusicWorkshopRankEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      WorldMusicWorkshopRankService.new(exp)
    end

    def export
      # TODO
    end
  end

  def initialize(entity)
    @entity = entity
  end

  def offset
    cat = @entity.username[-1].to_i
    raise NotFoundError.new('Entity', 'No Such Category') unless (0...6).include?(cat) # 6 Groups
    @entity.username[-1].to_i * WorldMusicWorkshopRankService.singleton_class::SONGS
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
          entity: "/static/world_music_workshop/#{WorldMusicWorkshopRankService.singleton_class::PAIRS[entity.pair_id][0] + offset}.mp3",
        },
        {
          label: 'B',
          entity: "/static/world_music_workshop/#{WorldMusicWorkshopRankService.singleton_class::PAIRS[entity.pair_id][1] + offset}.mp3",
        },
        {
          label: 'C',
          entity: "/static/world_music_workshop/#{WorldMusicWorkshopRankService.singleton_class::PAIRS[entity.pair_id][2] + offset}.mp3",
        },
      ],
    }
  end

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry Not Existed') if entry.nil?
    entry.option = options['option']
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
