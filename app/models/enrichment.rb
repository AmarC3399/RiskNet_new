class Enrichment < ApplicationRecord	
  belongs_to :owner, polymorphic: true
  belongs_to :field_list

  # Example enrichment for distance travelled
  # query_pattern:  "SELECT TOP 1 CAST('%s' AS geography).STDistance(user_geography_1) as result FROM authorisations WHERE card_number = '%s' "
  # order_clause:   "auth_date DESC"
  # contains_where: TRUE    (Is there a WHERE in the outer query?  Determines AND/WHERE use for owner filtering.)
  # placeholder_1:  user_geography_1
  # placeholder_2:  card_number
  # Owner: Combination of owner_type and owner_id to represent the hierarchy member that has defined the enrichment
  # FieldList: id of a FieldList instance which has a model type 'EnrichmentResult'. Indicates the column in which the result will be stored.

  def query(auth)

    query = query_pattern % [placeholder_1,placeholder_2,placeholder_3,placeholder_4].map{|p| auth.send(p) if p}.map{|p| p.methods.include?(:strftime) ? p.to_s(:db) : p}

    if owner_type != 'Installation'
      query = "#{query} #{contains_where ? 'AND' : 'WHERE'} #{owner_field}=#{owner_id}"
    end

    if order_clause
      query = "#{query} ORDER BY #{order_clause}"
    end

    query
  end

  def query_result(auth)
    r = ActiveRecord::Base.connection.execute(query(auth)).first
    r['result'] if r
  end

  def cache
    @field_list = self.field_list
    @owner = self.owner
  end

  def owner_field
    "#{owner_type.downcase}_id"
  end

# Class methods
  def self.process (enrichments, auth)
    # Filter enrichments to relevant owners only
    filtered_enrichments = enrichments.select {|e| (e.owner.is_a?(Member) && e.owner.id == auth.member_id ) ||
        (e.owner.is_a?(Client) && e.owner.id == auth.client_id ) ||
        (e.owner.is_a?(Merchant) && e.owner.id == auth.merchant_id ) ||
        (e.owner.is_a?(Installation))}
    # One result row per owner
    owners = filtered_enrichments.map {|e| e.owner}.uniq
    owners.each do |o|
      er = EnrichmentResult.new ({:owner_id => o.id, :owner_type => o.class.name})
      # Get each enrichment for this owner
      filtered_enrichments.group_by{|e| e.owner}[o].each do |e|
        # Set field in this owner's row to the retrieved value
        er[e.field_list.name.to_sym] = e.query_result(auth)
      end
      # Save and set parentage
      auth.enrichment_results << er
    end
  end
	
	def self.cached_enrichments
    Rails.cache.fetch('enrichments') { all.to_a }
	end
	
	def self.update_cached_enrichments
    Rails.cache.delete('enrichments')
		cached_enrichments
	end
	
end
