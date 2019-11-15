class CopyrightFullService < ExperimentService
  PAIR_SIZE = 17 * 3 * 2 # (Full + Melody + Lyrics) * Random
  class << self
    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'CopyrightFullEntry',
        )

        PAIR_SIZE.times.to_a.shuffle.each do |i|
          if i < PAIR_SIZE / 2
            CopyrightFullEntry.create(
              experiment: exp,
              pair_id: i,
            )
          else
            song_a = (0...17).to_a.sample(1)[0]
            song_b = ((0...17).to_a - [song_a]).sample(1)[0]
            CopyrightFullEntry.create(
              experiment: exp,
              pair_id: i,
              song_a: song_a,
              song_b: song_b,
            )
          end
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
      Experiment.where(
        model: 'CopyrightFullEntry',
      ).map do |exp|
        {
          username: exp.username,
          res: exp.entries.map { |row| {
            id: row.pair_id,
            similarity: row.similarity,
            infringe: row.infringe,
            answered: row.edited,
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
    pair_id = entity.pair_id

    res = {
      id: entity.id,
      progress: @entity.entries.where(edited: true).count.to_f / @entity.entries.count,
      wavs: [],
      lyrics: [],
    }

    if (0...17).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/full/#{pair_id}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/full/#{pair_id}b.mp3",
      }
    elsif (17...34).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/melody/#{pair_id - 17}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/melody/#{pair_id - 17}b.mp3",
      }
    elsif (34...51).include?(pair_id)
      res[:lyrics] << {
        label: 'A',
        entity: "#{pair_id - 34}a",
      }

      res[:lyrics] << {
        label: 'B',
        entity: "#{pair_id - 34}b",
      }
    elsif (51...68).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/full/#{entity.song_a}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/full/#{entity.song_b}b.mp3",
      }
    elsif (68...85).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_full/melody/#{entity.song_a}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_full/melody/#{entity.song_b}b.mp3",
      }
    elsif (85...102).include?(pair_id)
      res[:lyrics] << {
        label: 'A',
        entity: "#{entity.song_a}a",
      }

      res[:lyrics] << {
        label: 'B',
        entity: "#{entity.song_b}b",
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
