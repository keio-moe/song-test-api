class CopyrightNewWorkshopService < ExperimentService
  SONG_NUM = 4
  PAIR_SIZE = SONG_NUM * 3 * 2 # (Full + Melody + Lyrics) * Random
  class << self
    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'CopyrightNewWorkshopEntry',
        )

        PAIR_SIZE.times.to_a.shuffle.each do |i|
          if i < PAIR_SIZE / 2
            CopyrightNewWorkshopEntry.create(
              experiment: exp,
              pair_id: i,
            )
          else
            song_a = (0...SONG_NUM).to_a.sample(1)[0]
            song_b = ((0...SONG_NUM).to_a - [song_a]).sample(1)[0]
            CopyrightNewWorkshopEntry.create(
              experiment: exp,
              pair_id: i,
              song_a: song_a,
              song_b: song_b,
            )
          end
        end

        return CopyrightNewWorkshopService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'CopyrightNewWorkshopEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      CopyrightNewWorkshopService.new(exp)
    end

    def export
      Experiment.where(
        model: 'CopyrightNewWorkshopEntry',
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

    if (0...SONG_NUM).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_new_workshop/full/#{pair_id}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_new_workshop/full/#{pair_id}b.mp3",
      }
    elsif (SONG_NUM...SONG_NUM*2).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_new_workshop/melody/#{pair_id - SONG_NUM}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_new_workshop/melody/#{pair_id - SONG_NUM}b.mp3",
      }
    elsif (SONG_NUM*2...SONG_NUM*3).include?(pair_id)
      res[:lyrics] << {
        label: 'A',
        entity: "#{pair_id - SONG_NUM * 2}a",
      }

      res[:lyrics] << {
        label: 'B',
        entity: "#{pair_id - SONG_NUM * 2}b",
      }
    elsif (SONG_NUM*3...SONG_NUM*4).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_new_workshop/full/#{entity.song_a}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_new_workshop/full/#{entity.song_b}b.mp3",
      }
    elsif (SONG_NUM*4...SONG_NUM*5).include?(pair_id)
      res[:wavs] << {
        label: 'A',
        entity: "/static/copyright_new_workshop/melody/#{entity.song_a}a.mp3",
      }

      res[:wavs] << {
        label: 'B',
        entity: "/static/copyright_new_workshop/melody/#{entity.song_b}b.mp3",
      }
    elsif (SONG_NUM*5...SONG_NUM*6).include?(pair_id)
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
