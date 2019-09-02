class WorldMusicWorkshopSimilarityService < ExperimentService
  class << self
    SONGS = 5
    PAIRS = (0...SONGS).to_a.combination(2).to_a

    def create(options)
      raise NotFoundError.new('Experiment', 'Evaluation Not Finished') if Experiment.where(
        username: options['username'],
        model: 'WorldMusicWorkshopEvaluationEntry',
      )&.first.nil?

      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'WorldMusicWorkshopSimilarityEntry',
        )

        PAIRS.length.times.to_a.shuffle.each do |i|
          WorldMusicWorkshopSimilarityEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return WorldMusicWorkshopSimilarityService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'WorldMusicWorkshopSimilarityEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      WorldMusicWorkshopSimilarityService.new(exp)
    end

    def export
      Experiment.where(
        model: 'WorldMusicWorkshopSimilarityEntry',
      ).map do |exp|
        res = exp.entries.order(:pair_id).map do |pair|
          {
            song_a: PAIRS[pair.pair_id][0],
            song_b: PAIRS[pair.pair_id][1],
            similarity: pair.similarity,
            likeness: pair.likeness,
          }
        end

        similarity_matrix = Array.new(SONGS) { Array.new(SONGS) }
        likeness_matrix = Array.new(SONGS) { Array.new(SONGS) }
        res.each do |row|
          similarity_matrix[row[:song_a]][row[:song_b]] = row[:similarity]
          similarity_matrix[row[:song_b]][row[:song_a]] = row[:similarity]
          likeness_matrix[row[:song_a]][row[:song_b]] = row[:likeness]
          likeness_matrix[row[:song_b]][row[:song_a]] = row[:likeness]
        end

        { 
          username: exp.username,
          similarity: similarity_matrix.map { |row| row.join(',') }.join("\n"),
          likeness: likeness_matrix.map { |row| row.join(',') }.join("\n"),
        }
      end
    end
  end

  def initialize(entity)
    @entity = entity
  end

  def offset
    cat = @entity.username[0].to_i
    raise NotFoundError.new('Entity', 'No Such Category') unless (0...6).include?(cat) # 6 Groups
    @entity.username[0].to_i * WorldMusicWorkshopSimilarityService.singleton_class::SONGS
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
          entity: "/static/world_music_workshop/#{WorldMusicWorkshopSimilarityService.singleton_class::PAIRS[entity.pair_id][0] + offset}.mp3",
        },
        {
          label: 'B',
          entity: "/static/world_music_workshop/#{WorldMusicWorkshopSimilarityService.singleton_class::PAIRS[entity.pair_id][1] + offset}.mp3",
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
