require "spec_helper"

describe "Sequel::Plugins::Translatable" do
  before :all do
    DB.create_table! :items do
      primary_key :id
      String      :name_fr
      String      :name_en
      String      :value_fr
      String      :value_en
    end
    @klass = Class.new Sequel::Model do
      set_dataset :items
    end
  end
  after{ @klass.truncate }
  it "checks at least one attribute is given" do
    lambda{
      @klass.plugin :translatable
    }.should raise_error Sequel::Error, "please specify attributes to use for translatable plugin"
  end
  it "checks value isn't defined before plugin" do
    @klass.new.should_not respond_to :value
  end
  it "allows defining a single attribute" do
    @klass.plugin :translatable, :value
    @klass.new.should respond_to :value
  end
  it "allows defining multiple attributes" do
    @klass.plugin :translatable, [:name, :value]
    @klass.new.should respond_to :name
    @klass.new.should respond_to :value
  end
  it "gets value from current locale" do
    I18n.locale = :en
    @klass.plugin :translatable, :value
    m = @klass.new value_en: "Items", value_fr: "Objets"
    m.value.should == "Items"
    I18n.locale = :fr
    m.value.should == "Objets"
    I18n.locale = :en_master
    m.value.should == "Items"
    I18n.locale = :nl
    lambda{ m.value }.should raise_error NoMethodError
  end
  it "sets value from current locale" do
    I18n.locale = :en
    @klass.plugin :translatable, :value
    m = @klass.new value_en: "Items", value_fr: "Objets"
    m.value = "Objects"
    m.value_en.should == "Objects"
    m.value_hash.should == {en: "Objects", fr: "Objets"}
  end
  it "allows validating at least one language is required" do
    @klass.plugin :translatable, :value
    @klass.send :define_method, :validate do
      super()
      validates_at_least_one_language :value
    end
    m = @klass.new
    m.should_not be_valid
    m.errors.should == {
      value_en: ["at least one language is required"],
      value_fr: ["at least one language is required"],
    }
    m.value = "Objects"
    m.should be_valid
  end
  it "exposes the locales for an attribute" do
    @klass.locales_for("value").should == [:en, :fr]
    @klass.locales_for(:value).should == [:en, :fr]
  end
  it "exposes the translated attributes for an attribute" do
    @klass.translated_attributes_for("value").should == [:value_en, :value_fr]
    @klass.translated_attributes_for(:value).should == [:value_en, :value_fr]
  end
end
