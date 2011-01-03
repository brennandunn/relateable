module Relateable
  class ModelRelation < ActiveRecord::Base
    
    belongs_to :model, :polymorphic => true
    
  end
end