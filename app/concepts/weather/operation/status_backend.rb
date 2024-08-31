module Weather::Operation
  class StatusBackend < Trailblazer::Operation
    step :check_status

    def check_status(ctx, **)
      ctx[:status] = { status: 'OK' }
    end
  end
end

