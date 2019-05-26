class ResourceConflict < BaseError
  def initialize(reason)
    super(409, {
      reason: reason,
    })
  end
end
