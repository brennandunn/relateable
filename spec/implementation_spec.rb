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
  
  context "when creating a new record" do
    
    it "creates ModelRelation records for the record against every other record of it's class" do
      lambda { User.create }.should_not change(Relateable::ModelRelation, :count)
      
      lambda {
        @user.save
      }.should change(Relateable::ModelRelation, :count).by(2)
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
  
  context "when updating a record" do
    
    it "for now, destroys existing model relation records and recreates them" do
      @user.age = 21
      @user.save
      
      @user.age = 30
      @user.should_receive(:destroy_model_relations)
      @user.should_receive(:create_model_relations)
      @user.save
    end
    
  end
  
  context "when destroying a record" do
    
    it "removes relevant ModelRelation records" do
      User.create
      user = User.create
      
      lambda {
        user.destroy
      }.should change(Relateable::ModelRelation, :count).by(-2)
    end
    
  end

  context "finding related records" do
    
    before do
      User.relateable do
        factor :age do |a, b|
          difference = (a.age - b.age).abs
          if difference >= 20
            0.0
          else
            (20.0 - difference.to_f) / 20.0
          end
        end
      end
      
      @user.age = 21
      @user.save
      @a_few_years_younger = User.create :age => 14
      @close_in_age = User.create :age => 20
      @similar_in_age = User.create :age => 18
      @way_too_old = User.create :age => 45
    end
    
    it "orders the related users by relevancy score" do
      @user.related.should == [@close_in_age, @similar_in_age, @a_few_years_younger, @way_too_old]
    end
    
    it "can find the related score for another record" do
      @user.related_score_for(@similar_in_age).should == 0.85
    end
    
  end

end
