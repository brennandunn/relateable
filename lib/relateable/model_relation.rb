module Relateable
  class ModelRelation < ActiveRecord::Base
    
    belongs_to :model, :polymorphic => true
    
    after_create :create_inverse_relationship, :unless => :skip_inverse
    
    attr_accessor :skip_inverse
    attr_accessible :model_type, :skip_inverse, :model_id, :score, :associated_id
    
    def associated
      model_type.constantize.find(associated_id)
    end
    
    
    private
    
    def create_inverse_relationship
      self.class.create :model_id => associated_id, :model_type => model_type, :associated_id => model_id, :score => score, :skip_inverse => true
    end
    
  end
end