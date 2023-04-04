# == Schema Information
#
# Table name: criteria
#
#  id                   :integer          not null, primary key
#  detail_type          :string(255)
#  detail               :string(255)
#  constraint           :string(255)
#  value                :string(255)
#  right_operator       :string(255)
#  right_operator_value :integer
#  include_empty        :boolean          default(FALSE)
#  affects_priority     :boolean          default(FALSE)
#  description          :string(255)
#  rule_id              :integer
#  statistic_id         :integer
#  criteria_id          :integer
#  criteria_type        :string(255)
#  leftable_id          :integer
#  leftable_type        :string(255)
#  rightable_id         :integer
#  rightable_type       :string(255)
#  created_at           :timestamp        not null
#  updated_at           :timestamp        not null
#

class Criterion < ApplicationRecord

  schema_validations unless Rails.env.test?

  self.table_name = "criteria"
  belongs_to :rule, inverse_of: :criteria
  belongs_to :statistic, inverse_of: :criterion
  validate :rule_xor_statistic
  validates_presence_of :leftable, :rightable

  has_many :criteria_summaries, through: :leftable
  has_many :criteria_summaries, through: :rightable
  belongs_to :leftable, polymorphic: true
  belongs_to :rightable, polymorphic: true

  attr_accessor :leftable_attributes
  attr_accessor :rightable_attributes
  attr_accessor :skip_build_rightable

  #todo-an .. running this before validations means that leftable and rightable will be created
  # even if the criteria doesn't pass the validation and cannot be created
  # need to validate content before validation and create related records in before creation
  before_validation :build_leftable, only: :create
  before_validation :build_rightable, only: :create, unless: :skip_build_rightable

  include Authority::Abilities
  self.authorizer_name = 'StatisticsAuthorizer'

  validate :validate_attributes
  after_create { |c| c.generate_readable_description(false, true) } # :generate_readable_description

  def serializable_hash(options={})
    # original will allow you to access the original json object as provided by rails
    if options && options[:original]
      super
    elsif options && options[:include]
      super(include: options[:include])
    else
      super
    end
  end

  def validate_attributes
    if !self.rightable.valid?
      self.rightable.errors.full_messages.each do |error|
        errors.add(:base, error)
      end
    elsif !self.leftable.valid?
      self.leftable.errors.full_messages.each do |error|
        errors.add(:base, error)
      end
    end
  end

  def skip_build_rightable
    @skip_build_rightable || false
  end

  #protected

  # When building a rule with a criterion, the criterion could either evaluate this rule by comparing a field value in the
  # newly coming authorisation or the criterion could evaluate this rule with statistic result in historical record against
  # a specific value. In either way,the criterion need to specify a leftable field which associates this criterion
  # with either a FieldList or StatisticCalculation
  def build_leftable
    type = (@leftable_attributes || {})[:type]
    if type == "FieldList"
      self.leftable = FieldList.find(@leftable_attributes[:id])
    elsif type == "StatisticCalculation"
      #quick fix for the stat  calculation
      #       @leftable_attributes[:calculation][:type] = "AUTHORISATION"
      self.leftable = StatisticCalculation.new(@leftable_attributes[:calculation])
    elsif type == "DataList"
      self.leftable = DataList.find(@leftable_attributes[:id])
    end
  end

  # When a leftable attributes is selected(either a field or statistic), the criterion need to compare it against either a fix value
  # or the value of an attributes in the original newly coming authorisation. Or if the leftable attribute is statistic result, this
  # can also be a calculated value from another statistic result
  def build_rightable
    type = (@rightable_attributes || {})[:type]
    if type == "FieldList"
      self.rightable = FieldList.find(@rightable_attributes[:id])
      self.right_operator = @rightable_attributes[:right_operator]
      self.right_operator_value = @rightable_attributes[:right_operator_value]
    elsif type == "StatisticCalculation"
      self.rightable = StatisticCalculation.new(@rightable_attributes[:calculation])
      self.right_operator = @rightable_attributes[:right_operator]
      self.right_operator_value = @rightable_attributes[:right_operator_value]
    elsif type == "DataList"
      self.rightable = DataList.find(@rightable_attributes[:id])
    elsif type == "CriteriaParameter"
      self.rightable = CriteriaParameter.new(@rightable_attributes[:parameter])
    elsif type == "CriteriaCard"
      self.rightable = CriteriaCard.new(@rightable_attributes[:parameter])
    end
  end


  # private

  def rule_xor_statistic
    #checking if both are present or not..
    if self.rule.present? and self.statistic.present?
      errors.add(:base, :rule_xor_statistic)
    else
      if !self.rule.present? and !self.statistic.present?
        errors.add(:base, :rule_or_statistic)
      end
    end
  end

  def generate_readable_description(find_info=false, save_description=true, owner=nil)
    human_left = readable_left_side(find_info, owner)
    human_constraint = readable_constraint
    human_nulls = readable_null
    human_right = readable_right_side(find_info)

    desc = "#{human_left} #{human_constraint} #{human_right} #{human_nulls}"

    if save_description
      self.update_column(:description, desc)
    else
      desc
    end
  end

  def readable_constraint
    constraint = self.constraint

    return "is equal to" if constraint == "="
    return "is greater than" if constraint == ">"
    return "is less than" if constraint == "<"
    return "is greater than or equal to" if constraint == ">="
    return "is less than or equal to" if constraint == "<="
    return "is not equal to" if constraint == "<>"
    return "is in the list" if constraint == "IN"
    return "is not in the list" if constraint == "NOTIN"
    return "matches" if constraint == "LIKE"
    return "does not match" if constraint == "NOTLIKE"
  end

  def readable_null
    if include_empty
      "(including NULL)"
    end
  end

  def readable_left_side(find_info=false, owner=nil)
    if find_info
      case self.leftable_attributes[:type]
        when "FieldList"
           field_name = FieldListMappingOwner.where(owner_type: owner.first, owner_id: owner.last, field_list_id: self.leftable_attributes[:id]).first if owner
           if field_name.present?
              field_name.name.humanize.downcase 
           else   
              "#{self.leftable_attributes[:type].constantize.find(self.leftable_attributes[:id]).description.humanize.downcase}"
           end            
        when "StatisticCalculation"
          self.readable_calculation(self.leftable_attributes[:calculation])
      end
    else
      case self.leftable_type
        when "FieldList"
          "#{self.leftable.description.humanize.downcase}"
        when "StatisticCalculation"
          "#{self.leftable.description}"
      end
    end
  end

  def readable_calculation(calc)
    stat_desc = ""
    stat_desc << Statistic.find(calc[:statistic_id]).description
    stat_tframe = StatisticTimeframe.find(calc[:statistic_timeframe_id]).aggregate_level.upcase
    stat_desc << readable_period(calc[:from_period], calc[:to_period], stat_tframe)
    stat_desc
  end

  def readable_period(from=nil, to=nil, agg_level)
    period_desc = ''
    if agg_level== 'W'
      period_desc << " a #{get_time_type(agg_level).singularize} ago"
    else
      period_desc << " #{from} #{get_time_type(agg_level)} ago" if from && from > 0
      period_desc << " (ignoring last #{to}) " if to && to > 0
    end
    period_desc
  end

  def get_time_type (st_agg_level)
    interval = case st_agg_level
                 when 'H'
                   :hours
                 when 'D'
                   :days
                 when 'W'
                   :weeks
                 when 'M'
                   :months
                 when 'S'
                   :minutes
               end
    interval.to_s
  end

  def readable_right_operator(right_op, numeric_value=nil)

    # Words that never need pluralising8
    common_dictionary = {
        "-" => "minus",
        "+" => "plus",
        "%" => "% of",
        "/" => "divided by",
        "*" => "multiplied by"
    }

    returner = common_dictionary[right_op]

    # If we didn't find it yet
    unless returner
      # Only pluralise if value is greater than 1
      do_pluralize = false
      unless numeric_value.blank?
        numeric_value = numeric_value.to_i
        do_pluralize = numeric_value > 1
      end

      # Because the original phrases are plural, our humanized versions will also be
      # plural for consistency
      time_dictionary = {
          "MINSBEFORE" => "minutes before",
          "MINSAFTER" => "minutes after",
          "HRSBEFORE" => "hours before",
          "HRSAFTER" => "hours after",
          "DAYSBEFORE" => "days before",
          "DAYSAFTER" => "days after",
          "WKSBEFORE" => "weeks before",
          "WKSAFTER" => "weeks after",
          "MTHSBEFORE" => "months before",
          "MTHSAFTER" => "months after",
          "YRSBEFORE" => "years before",
          "YRSAFTER" => "years after"
      }

      time_phrase = time_dictionary[right_op]

      # If no plural required, then singularise the word
      if do_pluralize
        returner = time_phrase
      else
        words = time_phrase.split " "
        returner = "#{words.first.singularize} #{words.second}"
      end
    end

    # Don't forget the preceding space
    return " #{returner}"
  end

  def readable_right_side(find_info=false)

    if find_info
      case self.rightable_attributes[:type]
        when "FieldList", "DataList"
          if rightable_attributes[:right_operator_value].blank?
            "#{self.rightable_attributes[:type].constantize.find(self.rightable_attributes[:id]).description.humanize.downcase}"
          else
            op = self.readable_right_operator(self.rightable_attributes[:right_operator], self.rightable_attributes[:right_operator_value])
            "#{self.rightable_attributes[:right_operator_value]} #{op} #{self.rightable_attributes[:type].constantize.find(self.rightable_attributes[:id]).description.humanize.downcase}"
          end
        when "StatisticCalculation"
          res = self.readable_calculation(self.rightable_attributes[:calculation])
          if rightable_attributes[:right_operator_value].blank?
            res
          else
            op = self.readable_right_operator(self.rightable_attributes[:right_operator], self.rightable_attributes[:right_operator_value])
            "#{self.rightable_attributes[:right_operator_value]} #{op} #{res}"
          end
        when "CriteriaParameter"
          data_type = self.rightable_attributes[:parameter][:data_type]
          value = self.rightable_attributes[:parameter][:value]
          case data_type
            when "string"
              "the text value '#{value}'"
            when "datetime"
              "the date '#{value.try(:to_date).try(:strftime, "%d/%m/%Y")}'"
            when "integer"
              "the number #{value}"
            when "decimal"
              "the amount #{value}"
            when "boolean"
              "#{value}"
          end
        when "CriteriaCard"
          value = self.rightable_attributes[:parameter][:value]
          "'#{value}'"
      end
    else
      self_right_type = self.rightable_type
      case self_right_type
        when "FieldList", "DataList"
          res = "#{self.rightable.description.humanize.downcase}"
          if self.right_operator_value.blank?
            res
          else
            op = self.readable_right_operator(self.right_operator, self.right_operator_value)
            "#{self.right_operator_value} #{op} #{res}"
          end
        when "StatisticCalculation"
          res= "#{self.rightable.description}"
          if self.right_operator_value.blank?
            res
          else
            op = self.readable_right_operator(self.right_operator, self.right_operator_value)
            "#{self.right_operator_value} #{op} #{res}"
          end
        when "CriteriaParameter"
          data_type = self.rightable.data_type
          value = self.rightable.value
          case data_type
            when "string"
              "the text value '#{value}'"
            when "datetime"
              "the date '#{value.try(:to_date).try(:strftime, "%d/%m/%Y")}'"
            when "integer"
              "the number #{value}"
            when "decimal"
              "the amount #{value}"
            when "boolean"
              "#{value}"
          end
        when "CriteriaCard"
          value = self.rightable.masked_value
          "the card number '#{value}'"
        else
      end
    end
  end

  def resolve(scope)
    # Only works for Statistic Criteria
    lvalue = self.get_parameters_for_xable(self.leftable, table_name: scope.table_name)

    if self.rightable.is_a?(DataList)
      liv = Arel::Nodes::SqlLiteral.new('list_items.value')
      self.rightable.list_items.projections = [liv]
      scope.where(lvalue.in(self.rightable.list_items.order('frontend_name').reorder('').select('value').project()))
    else
      rvalue = self.get_parameters_for_xable(self.rightable)
      case
        when ['+', '-', '*', '/'].include?(self.right_operator)
          rvalue = Arel::Nodes::InfixOperation.new(self.right_operator, self.right_operator_value, rvalue)
        when self.right_operator == '%'
          rvalue = Arel::Nodes::InfixOperation.new('*', self.right_operator_value/100.0, rvalue)
        when (self.right_operator.include?('AFTER') || self.right_operator.include?('BEFORE'))
          rvalue = DatabaseFunctions.dateadd(rvalue, self.right_operator_value, self.right_operator)
      end if right_operator
      scope.where(lvalue.send(self.arel_constraint, rvalue))
    end

  end

  def left_string
    xable_string(self.leftable)
  end

  def right_string
    xable_string(self.rightable)
  end

  def xable_string(xable)
    if xable.is_a?(FieldList)
      quote_col(xable.name)
    elsif xable.is_a?(CriteriaParameter)
      ['string','datetime'].include?(xable.data_type) ? "'#{xable.value}'" : xable.value
    end
  end

  def right_items
    self.rightable.list_items.pluck(:value).map {|i|"'#{i}'"}.join(',') if self.rightable.is_a?(DataList)
  end

  def condition_text
    if self.rightable.is_a?(CriteriaParameter) && self.rightable.data_type == 'datetime' # Makes the clause irrelevant for covering indexes
      nil
    else
      if self.rightable_type = 'DataList'
        if rightable
          "(#{left_string} #{self.constraint_string} (SELECT #{quote_col('value')} FROM list_items WHERE data_list_id = #{rightable.id}))"
        end
      else
        rvalue = right_string
        case
          when ['+', '-', '*', '/'].include?(self.right_operator)
            rvalue = "#{self.right_operator_value} #{right_operator} #{right_string}"
          when self.right_operator = '%'
            rvalue = "#{self.right_operator_value}/100.0 * #{right_string}"
        end if self.right_operator
        "#{left_string} #{constraint_string} #{rvalue}"
      end
    end
  end

  def get_parameters_for_xable(xable, opts = {})
    case xable
      when FieldList
        # klass = Object.const_get xable.model_type
        # klass.arel_table[xable.name]
        Arel::Table.new(opts[:table_name] || authorisations)[xable.name]
      when StatisticCalculation
        Arel::Attributes::Decimal[xable.calculate]
      when CriteriaParameter, CriteriaCard
        xable.value
      # when DataList
      #   # scope = ListItem.where(:data_list_id => xable.id).select(:value)
      #   Arel.sql(xable.list_items.select(:value))
      #   # "(#{scope.to_sql})"
      else
        nil
    end
  end

  def arel_constraint
    case self.constraint
      when 'NOTLIKE'
        :does_not_match
      when '='
        :eq
      when '>'
        :gt
      when '>='
        :gteq
      when 'IN'
        :in
      when '<'
        :lt
      when '<='
        :lteq
      when 'LIKE'
        :matches
      when '<>' || '!='
        :not_eq
      when 'NOTIN'
        :not_in
      else
        self.constraint
    end
  end

  def constraint_string
    case self.constraint
      when 'NOTLIKE'
        'NOT LIKE'
      when 'NOTIN'
        'NOT IN'
      else
        self.constraint
    end
  end

  # Puts appropriate quotes based on adapter in use
  def quote_col(name)
    ActiveRecord::Base.connection.quote_column_name(name)
  end

end

