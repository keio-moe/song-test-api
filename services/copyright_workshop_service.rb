class CopyrightWorkshopService < ExperimentService
  class << self
    PAIR_SIZE = 28

    def create(options)
      DB.transaction do
        exp = Experiment.create(
          username: options['username'],
          model: 'CopyrightWorkshopEntry',
        )

        PAIR_SIZE.times.to_a.shuffle.each do |i|
          CopyrightWorkshopEntry.create(
            experiment: exp,
            pair_id: i,
          )
        end

        return CopyrightWorkshopService.new(exp)
      end
    end
  
    def find(options)
      exp = Experiment.where(
        username: options['username'],
        model: 'CopyrightWorkshopEntry',
      )&.first
      raise NotFoundError.new('Experiment', 'No Such Experiment Existed') if exp.nil?
      CopyrightWorkshopService.new(exp)
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
      wavs: ["/static/copyright_workshop/#{entity.pair_id}.mp3"],
    }
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
