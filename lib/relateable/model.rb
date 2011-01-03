module Relateable
  module Model
    
    def relateable_context
      @@relateable_context
    end
    
    def relateable(&block)
      send :include, InstanceMethods
      @@relateable_context = Context.new(self, &block)
      after_create  :create_model_relations
      after_update  :update_model_relations
      after_destroy :destroy_model_relations
    end
    
    module InstanceMethods
      
      def related
        self.class.where(
          :id => ModelRelation.where("(model_id = :id OR associated_id = :id) AND model_type = :class_name", { :id => id, :class_name => self.class.name }).map(&:id)
        )
      end
      
      private
      
      def create_model_relations
        (self.class.all - [self]).each do |associated|
          relation = ModelRelation.create :model => self, :associated_id => associated.id, :score => self.class.relateable_context.match(self, associated)
        end
      end
      
      def destroy_model_relations
        ModelRelation.where(:model_type => self.class.name).scoping do
          ModelRelation.where(:model_id => id).first.try(:destroy)
          ModelRelation.where(:associated_id => id).first.try(:destroy)
        end
      end
      
    end
    
  end
end