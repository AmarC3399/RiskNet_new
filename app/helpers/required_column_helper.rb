module RequiredColumnHelper
  def send_schema
    attributes = self.class.column_names - self.class::DISCOUNTED_COLUMNS
    attributes.collect do |v|
      if self.class::REQUIRED_COLUMNS.include?(v)
        {column: v, required: true }
      else
        {column: v, required: false}
      end
    end
  end
end