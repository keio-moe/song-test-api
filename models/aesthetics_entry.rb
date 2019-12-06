class AestheticsEntry < Sequel::Model
  many_to_one :experiment
end
