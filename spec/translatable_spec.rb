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
    expect do
      @klass.plugin :translatable
    end.to raise_error Sequel::Error, "please specify attributes to use for translatable plugin"
  end
  it "checks value isn't defined before plugin" do
    expect( @klass.new ).not_to respond_to :value
  end
  it "allows defining a single attribute" do
    @klass.plugin :translatable, :value
    expect( @klass.new ).to respond_to :value
  end
  it "allows defining multiple attributes" do
    @klass.plugin :translatable, [:name, :value]
    expect( @klass.new ).to respond_to :name
    expect( @klass.new ).to respond_to :value
  end
  it "gets value from current locale" do
    I18n.locale = :en
    @klass.plugin :translatable, :value
    m = @klass.new value_en: "Items", value_fr: "Objets"
    expect( m.value ).to eq "Items"
    I18n.locale = :fr
    expect( m.value ).to eq "Objets"
    I18n.locale = :en_master
    expect( m.value ).to eq "Items"
    I18n.locale = :nl
    expect do
      m.value
    end.to raise_error NoMethodError
  end
  it "sets value from current locale" do
    I18n.locale = :en
    @klass.plugin :translatable, :value
    m = @klass.new value_en: "Items", value_fr: "Objets"
    m.value = "Objects"
    expect( m.value_en ).to eq "Objects"
    expect( m.value_hash ).to eq({en: "Objects", fr: "Objets"})
  end
  it "allows validating at least one language is required" do
    @klass.plugin :translatable, :value
    @klass.send :define_method, :validate do
      super()
      validates_at_least_one_language :value
    end
    m = @klass.new
    expect( m.valid? ).to be false
    expect( m.errors ).to eq({
      value_en: ["at least one language is required"],
      value_fr: ["at least one language is required"],
    })
    m.value = "Objects"
    expect( m.valid? ).to be true
  end
  it "exposes the locales for an attribute" do
    expect( @klass.locales_for("value") ).to eq [:en, :fr]
    expect( @klass.locales_for(:value) ).to eq [:en, :fr]
  end
  it "exposes the translated attributes for an attribute" do
    expect( @klass.translated_attributes_for("value") ).to eq [:value_en, :value_fr]
    expect( @klass.translated_attributes_for(:value) ).to eq [:value_en, :value_fr]
  end
end
