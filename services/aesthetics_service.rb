class AestheticsService < ExperimentService
  class << self
    PAIR_SIZE = 100

    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'AestheticsEntry',
        )

        PAIR_SIZE.times.to_a.shuffle.each do |i|
          AestheticsEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return AestheticsService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'AestheticsEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      AestheticsService.new(exp)
    end

    def export
      Experiment.where(
        model: 'AestheticsEntry',
      ).map do |exp|
        {
          username: exp.username,
          res: exp.entries.map { |row| {
            id: row.pair_id,
            pleasant: row.pleasant,
            consonant: row.consonant,
            beautiful: row.beautiful,
          } }
        }
      end
    end
  end

  def initialize(entity)
    @entity = entity
  end

  def next
    entity = @entity.entries.where(edited: false).order(:id).first
    raise NotFoundError.new('Entity', 'Experiment Finished') if entity.nil?
    wav = ''

    if entity.pair_id < 25
      wav = "har_dichotic_#{entity.pair_id + 1}.mp3"
    elsif entity.pair_id < 50
      wav = "harmonic_#{entity.pair_id - 24}.mp3"
    elsif entity.pair_id < 75
      wav = "mel_dichotic_#{entity.pair_id - 49}.mp3"
    else
      wav = "melodic_#{entity.pair_id - 74}.mp3"
    end

    {
      id: entity.id,
      progress: @entity.entries.where(edited: true).count.to_f / @entity.entries.count,
      wavs: [{
        label: 'Sample',
        entity: "/static/aesthetics/#{wav}",
      }],
    }
  end

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry Not Existed') if entry.nil?
    entry.pleasant = options['pleasant']
    entry.consonant = options['consonant']
    entry.beautiful = options['beautiful']
    entry.edited = true
    entry.save
    nil
  end

  def destroy
    @entity.entries.delete
    @entity.delete
  end
end
