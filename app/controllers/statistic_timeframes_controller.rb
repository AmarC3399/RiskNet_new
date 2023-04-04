class StatisticTimeframesController < ApplicationController
  authorize_actions_for StatisticTimeframe

  def index
    @timeframes = StatisticTimeframe.all
    render json: { timeframes: @timeframes.as_json(only: [:id, :timeframe_type]) }
  end
end
