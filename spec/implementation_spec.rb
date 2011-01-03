require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Using Relateable in a model" do

  before do
    User.relateable {}
    @user = User.new
  end

  it "adds a #related instance method" do
    @user.save
    @user.respond_to?(:related).should be_true
  end
  
  it "returns an ActiveRecord::Relation" do
    @user.save
    @user.related.should be_an_instance_of ActiveRecord::Relation
  end
  
  context "when creating a new record" do
    
    it "creates ModelRelation records for the record against every other record of it's class" do
      lambda { User.create }.should_not change(Relateable::ModelRelation, :count)
      
      lambda {
        @user.save
      }.should change(Relateable::ModelRelation, :count).by(1)
    end
    
    it "stores the score of the relationship in the ModelRelation record" do
      User.relateable do
        factor :same_age do |a, b|
          a.age == b.age
        end
      end
      
      @user.age = 21 ; @user.save
      @other_user = User.create :age => 21
      Relateable::ModelRelation.last.score.should == 1.0
    end
    
  end
  
  context "when destroying a record" do
    
    it "removes relevant ModelRelation records" do
      User.create
      user = User.create
      
      lambda {
        user.destroy
      }.should change(Relateable::ModelRelation, :count).by(-1)
    end
    
  end

  context "finding related records" do
    
    before do
      @user.age = 21
      @a_few_years_younger = User.create :age => 14
      @close_in_age = User.create :age => 20
      @similar_in_age = User.create :age => 18
      @way_too_old = User.create :age => 45
    end
    
    it "orders the related users by relevancy score" do
      @user.related.should == [@close_in_age, @similar_in_age, @a_few_years_younger, @way_too_old]
    end
    
  end

end