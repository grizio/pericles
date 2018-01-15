class ApiErrorsController < ApplicationController
  include ProjectRelated

  layout 'full_width_column'
  lazy_controller_of :api_error, helper_method: true

  def index
    @api_errors = project.api_errors.sort_by { |api_error| api_error.name.downcase }
  end

  def show
    respond_to do |format|
      format.html
      format.json_schema do
        render(
          json: JSONSchemaWrapper.new(
            api_error.json_schema,
            params[:root_key],
            ActiveModel::Type::Boolean.new.cast(params[:is_collection]),
          ).execute
        )
      end
    end
  end

  def new
  end

  def edit
  end

  def create
    if api_error.save
      redirect_to project_api_error_path(project, api_error)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def update
    if api_error.update(api_error_params)
      redirect_to project_api_error_path(project, api_error)
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    api_error.destroy
    redirect_to project_api_errors_path(project)
  end

  private

  def new_api_error
    project.api_errors.build
  end

  def build_api_error_from_params
    project.api_errors.build(api_error_params) if params.has_key? :api_error
  end

  def api_error_params
    params.require(:api_error).permit(
      :name,
      :json_schema
    )
  end
end