class StatisticsOperationsController < ApplicationController
  authorize_actions_for Statistic
  def index
    @statistics_operations = StatisticsOperation.all

    render json: { operations: @statistics_operations.as_json(only: [:id, :op_code]) }
  end
  
end
