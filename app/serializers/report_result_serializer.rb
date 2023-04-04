class ReportResultSerializer < ApplicationSerializer
  attributes :id, :timestamps, :finished, :start_date, :end_date, :executed_by, :deleted, :executed_by_id, :report_id, :created_at, :updated_at, :result_check

  def result_check
    object.result.present?
  end
end
