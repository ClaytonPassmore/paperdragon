module Paperdragon
  class Paperclip
    module Model
      def self.included(base)
        base.send :include, Paperdragon::Model
        base.extend ClassMethods
      end

      module ClassMethods
        def processable(name, attachment_class)
          super # defines #image

          # this overrides #image (or whatever the name is) from Paperclip::Model::processable.
          # This allows using both paperclip's `image.url(:thumb)` and the new paperdragon style
          # `image(:thumb).url`.
          mod = Module.new do
            define_method name do # e.g. Avatar#image
              Proxy.new(self, attachment_class)  # provide paperclip DSL.
            end
          end
          include mod
        end
      end


      # Needed to expose Paperclip's DSL, like avatar.image.url(:thumb).
      class Proxy
        def initialize(model, attachment_class)
          @attachment = attachment_class.new(model)
        end

        def [](*args)
          @attachment[*args]
        end

        def url(style)
          @attachment[style].url # Avatar::Photo.new(avatar, :thumb).url
        end
      end
    end
  end
end