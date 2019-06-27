EXPERIMENT_ROUTE = proc do
  # Get Next Entity in the Experiment
  get '/:experiment' do |experiment|
    service = UtilService.experiment(experiment)
    {
      experiment: experiment,
      data: service.find(params).next,
    }.to_json
  end

  # Create user Experiment
  post '/:experiment' do |experiment|
    service = UtilService.experiment(experiment)
    res = service.create(JSON.parse(request.body.read))
    yajl :empty
  rescue Sequel::UniqueConstraintViolation => _e
    raise ResourceConflict.new('Experiment Existed')
  end

  # Update User Result
  put '/:experiment' do |experiment|
    service = UtilService.experiment(experiment)
    params = JSON.parse(request.body.read)
    service.find(params).update(params)
    yajl :empty
  end

  # Delete User Experiment
  delete '/:experiment' do |experiment|
    service = UtilService.experiment(experiment)
    service.find(JSON.parse(request.body.read)).destroy
    yajl :empty
  end

  # Export Datasets
  get '/:experiment/export' do |experiment|
    service = UtilService.experiment(experiment)
    JSON.pretty_generate service.export
    # yajl :export, locals: service.export
  end
end
