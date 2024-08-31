module Health
  class CheckOperation < Trailblazer::Operation
    step :success

    def success(options, **)
      options['result.success'] = true
    end
  end
end
