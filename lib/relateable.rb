require 'active_record'

module Relateable
  autoload :Model,          'relateable/model'
  autoload :ModelRelation,  'relateable/model_relation'
  autoload :Context,        'relateable/context'
end

ActiveRecord::Base.extend Relateable::Model