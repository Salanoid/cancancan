module CanCan
  class ResourceAuthorization # :nodoc:
    attr_reader :params
    
    def initialize(controller, params, options = {})
      @controller = controller
      @params = params
      @options = options
    end
    
    def load_and_authorize_resource
      load_resource
      authorize_resource
    end
    
    def load_resource
      unless collection_actions.include? params[:action].to_sym
        if new_actions.include? params[:action].to_sym
          resource.build(params[model_name.to_sym])
        elsif params[:id]
          resource.find(params[:id])
        end
      end
    end
    
    def authorize_resource
      @controller.unauthorized! if @controller.cannot?(params[:action].to_sym, resource.model_instance || resource.model_class)
    end
    
    private
    
    def resource
      @resource ||= ControllerResource.new(@controller, model_name, parent_resource)
    end
    
    def parent_resource
      parent = nil
      [@options[:nested]].flatten.compact.each do |name|
        parent = ControllerResource.new(@controller, name, parent)
        parent.find(@params["#{name}_id".to_sym])
      end
      parent
    end
    
    def model_name
      params[:controller].split('/').last.singularize
    end
    
    def collection_actions
      [:index] + [@options[:collection]].flatten
    end
    
    def new_actions
      [:new, :create] + [@options[:new]].flatten
    end
  end
end
