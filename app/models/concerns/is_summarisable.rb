module IsSummarisable
  extend ActiveSupport::Concern

  attr_accessor :summary2

  module ClassMethods
    attr_accessor :summaries

    def is_summarisable
      has_many :criteria_summaries, as: :data
      after_create :create_summary
      before_destroy :destroy_summary
    end

  end

  def summary
    if @summary2.nil?
      @summary ||= CriteriaSummary.where(data_id: self.id, data_type: self.class.name).select(:id, :data_type, :data_id).first
    else
      @summary ||= @summary2
    end
  end

  def serializable_hash(options=nil)
    #super
    if options and options[:original]
      super
    elsif options and options[:for_jpos]
      super(only: options[:only],include: options[:include],except: options[:except]).merge(unique_id: self.summary.as_json)
    elsif options
      super(only: options[:only],include: options[:include],except: options[:except])
    else
      super.merge(unique_id: self.summary.as_json)
    end
  end

  protected

  def create_summary
    # Create it if it doesn't already exist
    CriteriaSummary.find_or_create_by!(data_id: self.id, data_type: self.class.name)
  end

  def destroy_summary
    CriteriaSummary.where(data_id: self.id, data_type: self.class.name).destroy_all
  end

end