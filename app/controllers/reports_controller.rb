class ReportsController < ApplicationController
  def index
  end

  def show
  end

  def create
  end

  def update
  end

  def clone
  end

  def download
  end

  def disable
  end

  def results
     results = Report.find(params[:id]).report_results
    render html: results, status: :ok
  end

  def execute
  end

  def disable_result
  end

  def result
  end

  def result_downloads
  end

  def result_download
  end
end
