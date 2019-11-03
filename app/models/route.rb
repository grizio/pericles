class Route < ApplicationRecord
  enum http_method: [:GET, :POST, :PUT, :PATCH, :DELETE]

  has_many :request_headers, inverse_of: :http_message, as: :http_message, class_name: 'Header', dependent: :destroy
  has_many :request_query_parameters, inverse_of: :route, class_name: 'QueryParameter', dependent: :destroy
  has_many :responses, inverse_of: :route, dependent: :destroy
  has_many :resource_representations, through: :responses
  has_many :reports, dependent: :destroy

  belongs_to :resource, inverse_of: :routes
  belongs_to :request_resource_representation, class_name: 'ResourceRepresentation'
  has_many :security_scheme_assignments
  has_many :security_schemes, through: :security_scheme_assignments

  delegate :project, to: :resource

  accepts_nested_attributes_for :request_headers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :request_query_parameters, allow_destroy: true, reject_if: :all_blank

  validates :http_method, presence: true
  validates :url, presence: true
  validates :resource, presence: true, uniqueness: { scope: [:http_method, :url] }
  validate :request_resource_representation_must_belongs_to_project
  validate :security_schemes_must_belong_to_project

  audited
  has_associated_audits

  before_save :remove_obsolete_fields

  def request_json_instance
    GenerateJsonInstanceService.new(request_json_schema).execute if request_json_schema
  end

  def request_json_schema
    if request_resource_representation
      JSONSchemaBuilder.new(
        request_resource_representation,
        is_collection: request_is_collection,
        root_key: request_root_key
      ).execute
    end
  end

  def mock_path
    url.sub(/^\//, '').gsub(/:[^\/]+/, '1')
  end

  def request_can_have_body
    self.POST? || self.PUT? || self.PATCH?
  end

  def can_have_query_params
    self.GET?
  end

  private

  def remove_obsolete_fields
    request_query_parameters.destroy_all unless can_have_query_params
    unless request_can_have_body
      self.request_resource_representation_id = nil
      self.request_is_collection = false
      self.request_root_key = ''
    end
  end

  def request_resource_representation_must_belongs_to_project
    return unless request_resource_representation
    return if request_resource_representation.project == project
    errors.add(:request_resource_representation, :request_resource_representation_must_belongs_to_project)
  end

  def security_schemes_must_belong_to_project
    puts "tst"
    puts security_schemes
    puts "sts"
    return unless security_schemes
    security_schemes.each do |security_scheme|
      errors.add(:security_schemes, :security_schemes_must_belong_to_project) if security_scheme.project != project
    end
  end
end
