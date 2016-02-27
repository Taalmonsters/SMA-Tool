class TwoColumnLayoutGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :controller, :type => :string
  argument :page, :type => :string
  class_option :stylesheet, :type => :boolean, :default => true, :description => "Include stylesheet file"
  class_option :copyright, :type => :boolean, :default => true, :description => "Include copyright footer"
  
  def generate_layout
    copy_file "stylesheet.scss", "app/assets/stylesheets/two_column_layout.scss" if options.stylesheet?
    template "layout.html.erb", "app/views/#{controller_name}/#{page_name}.html.erb"
    template "_copyright.html.erb", "app/views/layouts/_copyright.html.erb" if options.copyright?
  end
  
  private
  
  def controller_name
    controller.underscore
  end
  
  def page_name
    page.underscore
  end
  
end
