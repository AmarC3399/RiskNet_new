class ProcessingError< ApplicationRecord
  RESPONSE_CODES = {
    '0' => 'Accept',
    '1' => 'Review',
    '5' => 'Decline',
    '6' => 'Rule Not Evaluated',
    '50' => 'Invalid MTI',
    '51' => 'Valid MTI wrong message format',
    '52' => 'Wrong message format',
    '53' => 'Exception in parsing Message'
  }

  RESPONCE_DESCRIPTIONS = {
    '900' => 'Time out in Auth Enrichment in Rails',
    '901' => 'Time out in Rule Evaluation in Rules Processing',
    '902' => 'Invalid Currency Code Mapped in the currency conversion table',
    '903' => 'Invalid Currency Code in the ISO Message',
    '904' => 'Currency Mapping not done'
  }

  attr_accessor :code, :description

  def self.error_description(code)
    RESPONSE_CODES.keys.include?(code) ? RESPONSE_CODES[code] : 'unexisting code'
  end

  def self.response_code_description(code)
    RESPONCE_DESCRIPTIONS.keys.include?(code) ? RESPONCE_DESCRIPTIONS[code] : 'unexisting code'
  end
end
