class Experiment < Sequel::Model
  def entries
    object = Object.const_get(self[:model])
    object.where(experiment_id: self.id)
  end
end
