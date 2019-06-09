class CopyrightFullService < ExperimentService
  class << self
    PAIR_SIZE = 14 * 3 # Full + Melody + Lyrics

    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'CopyrightFullEntry',
        )

        PAIR_SIZE.times.to_a.shuffle.each do |i|
          CopyrightFullEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return CopyrightFullService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'CopyrightFullEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      CopyrightFullService.new(exp)
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
    pair_id = entity.pair_id

    res = {
      id: entity.id,
      progress: @entity.entries.where(edited: true).count.to_f / @entity.entries.count,
      wavs: [],
      lyrics: [],
    }

    if (0...14).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/full/#{pair_id}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/full/#{pair_id}b.mp3",
      }
    elsif (14...28).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/melody/#{pair_id - 14}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/melody/#{pair_id - 14}b.mp3",
      }
    elsif (28...42).include?(pair_id)
      res[:lyrics] << {
        label: 'A',
        entity: "#{pair_id - 28}a",
      }

      res[:lyrics] << {
        label: 'B',
        entity: "#{pair_id - 30}b",
      }
    end
    
    res
  end

  def update(options)
    entry = @entity.entries.where(id: options['id'])&.first
    raise NotFoundError.new('Entry Not Existed') if entry.nil?
    entry.similarity = options['similarity']
    entry.infringe = options['infringe']
    entry.edited = true
    entry.save
    nil
  end

  def destroy
    @entity.entries.delete
    @entity.delete
  end
end
