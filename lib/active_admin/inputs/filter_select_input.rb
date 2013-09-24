module ActiveAdmin
  module Inputs
    class FilterSelectInput < ::Formtastic::Inputs::SelectInput
      include FilterBase

      # If MetaSearch already responds to the given method, just use it.
      #
      # Otherwise:
      # When it's a HABTM or has_many association, Formtastic builds "object_ids".
      # That doesn't fit our scenario, so we override it here.
      def input_name
        return method if @object.respond_to? method

        name = method.to_s

        10.times { puts "\n" }

        puts "before: #{name}"

        if name =~ /device_accreditations/
          name.concat '_id'
        else
          name.concat '_id' if reflection
          name.concat multiple? ? '_in' : '_eq'
        end

        10.times { puts "\n" }

        puts "after: #{name}"

        name
      end

      # Include the "Any" option if it's a dropdown, but not if it's a multi-select.
      def input_options
        super.merge :include_blank => multiple? ? false : I18n.t('active_admin.any')
      end

      # was "#{object_name}[#{association_primary_key}]"
      def input_html_options_name
        "#{object_name}[#{input_name}]"
      end

      # Would normally return true for has_many and HABTM, which would subsequently
      # cause the select field to be multi-select instead of a dropdown.
      def multiple_by_association?
        false
      end

      # Provides an efficient default lookup query if the attribute is a DB column.
      def collection
        if !options[:collection] && column
          pluck_column
        else
          super
        end
      end

      def pluck_column
        klass.reorder("#{method} asc").uniq.pluck method
      end

    end
  end
end
