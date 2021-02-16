class IndianMusicEvaluationService < ExperimentService
    class << self
      SONG_SIZE = 20
  
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
              song_id: pair.song_id,
              instrument: pair.overlap,
              creativity: pair.creativity,
              likeness: pair.likeness,
              tempo: pair.tempo,
              consonance: pair.consonance,
              emotion: pair.emotion,
              decoration: pair.decoration,
              range: pair.range,
              quality: pair.quality,
              rhythm: pair.rhythm,
              excitingness: pair.excitingness,
              groove: pair.groove,
              timbre: pair.timbre,
              instrument_vocals: pair.instrument_vocals,
              instrument_overlap: pair.instrument_overlap,
              instrument_tone_blend: pair.instrument_tone_blend,
              instrument_rhythm_blend: pair.instrument_tone_blend,
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
      raise NotFoundError.new('Entry does not exist') if entry.nil?
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
      entry.instrument_vocals = options['instrument_vocals']
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
  