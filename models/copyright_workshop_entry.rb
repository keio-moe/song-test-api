class CopyrightWorkshopEntry < Sequel::Model
  many_to_one :experiment
end
