module Sequel
  module Plugins
    module Translatable
      def self.configure(model, attributes = [])
        attributes = [*attributes]
        raise Error, "please specify attributes to use for translatable plugin" if attributes.empty?
        attributes.each do |attribute|
          model.class_eval <<-EOS, __FILE__, __LINE__
            def #{attribute}=(value)
              send "#{attribute}_\#{base_locale}=", value
            end
            def #{attribute}
              send "#{attribute}_\#{base_locale}"
            end
            def #{attribute}_hash
              self.class.locales_for("#{attribute}").each_with_object({}) do |locale, accu|
                accu[locale] = send "#{attribute}_\#{locale}"
              end
            end
          EOS
        end
      end
      module ClassMethods
        def locales_for(attribute)
          @attribute_locales ||= {}
          @attribute_locales[attribute.to_sym] ||= columns.map do |column|
            $1 if column=~/\A#{Regexp.escape attribute}_(.+)\z/
          end.compact.sort.map(&:to_sym)
        end
        def translated_attributes_for(attribute)
          @translated_attributes ||= {}
          @translated_attributes[attribute.to_sym] ||= locales_for(attribute).map do |locale|
            "#{attribute}_#{locale}".to_sym
          end
        end
      end
      module DatasetMethods
      end
      module InstanceMethods
        def validates_at_least_one_language(attribute)
          hash = send "#{attribute}_hash"
          hash.keys.each do |locale|
            errors.add :"#{attribute}_#{locale}", "at least one language is required"
          end if hash.values.all?{|value| value.to_s.strip.empty?}
        end
      private
        def base_locale
          I18n.locale.to_s[0..1]
        end
      end
    end
  end
end
