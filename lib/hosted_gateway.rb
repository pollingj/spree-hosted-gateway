require 'spree_core'

module HostedGateway
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      
      Spree::CheckoutController.send(:include, HostedGateway::CheckoutControllerExt)
      Spree::Admin::PaymentsController.send(:include, HostedGateway::AdminPaymentsControllerExt)
      
      initializer "spree_ccavenue.register.payment_method", :after => "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods << ExternalGateway
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end

