require 'test_helper'

class AuditsControllerTest < ControllerWithAuthenticationTest
  setup do
    @project = create(:project)
    resource = create(:resource, project: @project)
    route = create(:route, resource: resource)
    create(:response, route: route)
    create(:header, http_message: route)
    resource_representation = create(:resource_representation, resource: resource)
    create(:attribute, parent_resource: resource)
    create(:attributes_resource_representation, parent_resource_representation: resource_representation)
  end

  test 'should get index' do
    assert Audited::Audit.count.positive?

    get project_audits_path(@project)

    assert_response :success
  end
end
