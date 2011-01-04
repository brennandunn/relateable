require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Creating a context for a class, which determines how to generate a comparison score" do
  
  before do
    @context = Relateable::Context.new(User)
    @user_a = User.create
    @user_b = User.create
  end
  
  it "creates perfect matches everytime when there are no factors" do
    @context.match(@user_a, @user_b).should == 1.0
  end
  
  context "defining factors" do
    
    it "accepts a name and a block as a minimum, and defaults the weight to 1" do
      @context.factor(:always_half) { 0.5 }
      factor = @context.factors.first
      factor.weight.should == 1
      factor.name.should == :always_half
    end
    
    it "can override the default weight" do
      @context.factor(:very_important, :weight => 10) { 1.0 }
      factor = @context.factors.first
      factor.weight.should == 10
    end
    
    it "returns a score comparing two records" do
      @context.factor :distance_in_age_on_20_year_scale do |user_a, user_b|
        difference = (user_a.age - user_b.age).abs
        (20.0 - difference.to_f) / 20.0
      end
      factor = @context.factors.first
      
      # users with same age are 1.0
      @user_a.age, @user_b.age = 21, 21
      factor.match(@user_a, @user_b).should == 1.0
      
      # users 10 years apart are 0.5
      @user_a.age, @user_b.age = 20, 30
      factor.match(@user_a, @user_b).should == 0.5
    end
    
    it "returns 1.0 for true returns and 0.0 for false returns" do
      factor = @context.factor(:true) { true }
      factor.match(@user_a, @user_b).should == 1.0
      
      factor = @context.factor(:false) { false }
      factor.match(@user_a, @user_b).should == 0.0
    end
    
  end
  
  context "calculating scores" do
    
    it "runs through each factor, creates a score, multiplies the score by the factor weight, then divides the score sum by factor count" do
      @context.factor(:a) { 1.0 }
      @context.factor(:b) { 0.0 }
      @context.factor(:c, :weight => 2) { 1.0 }
      @context.match(@user_a, @user_b).should == 0.75
    end
    
  end
  
end