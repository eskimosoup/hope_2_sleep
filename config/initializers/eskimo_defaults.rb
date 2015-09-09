module ActionView
  module Helpers
    module AssetTagHelper
      def image_tag_with_defaults(source, options={})
        options[:vspace] ||= 0
        options[:hspace] ||= 0
        options[:border] ||= 0
        image_tag_without_defaults(source, options)
      end
      alias_method_chain :image_tag, :defaults
    end
  end
end


