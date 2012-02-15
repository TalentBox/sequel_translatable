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
              @#{attribute}_locales ||= columns.collect do |column|
                $1 if column=~/\\A#{Regexp.escape attribute}_(.+)\\z/
              end.compact.sort.collect(&:to_sym)
              hash = {}
              @#{attribute}_locales.each do |locale|
                hash[locale] = send "#{attribute}_\#{locale}"
              end
              hash
            end
          EOS
        end
      end
      module ClassMethods
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
