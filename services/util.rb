class UtilService
  class << self
    def experiment(name)
      service_name = name.split('_').map(&:capitalize).join
      service = Object.const_get("#{service_name}Service")
      raise BadRequestError.new('Service Not Match') unless service < ExperimentService
      service
    end
  end
end
