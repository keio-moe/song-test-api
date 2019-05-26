class ExperimentService
  class << self
    def create(options)
      raise NotImplementedError.new
    end
  
    def find(options)
      raise NotImplementedError.new
    end

    def export
      raise NotImplementedError.new
    end
  end

  def initialize(entity)
    raise NotImplementedError.new
  end

  def next
    raise NotImplementedError.new
  end

  def update(options)
    raise NotImplementedError.new
  end

  def destroy
    raise NotImplementedError.new
  end
end
