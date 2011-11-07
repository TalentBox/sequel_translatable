sequel_translatable
===================

Translate model attributes for sequel.

Dependencies
------------

* Ruby >= 1.9.2
* gem "i18n"
* gem "sequel"

Usage
-----

* Declare translatable attribute inside your model:

        class MyModel < Sequel::Model
          plugin :translatable, :value
        end

* or for multiple attributes:

        class MyModel < Sequel::Model
          plugin :translatable, [:name, :value]
        end

* then:

        I18n.locale
        -> :en
        m = MyModel.new value_en: "Item", value_fr: "Objet"
        m.value
        -> "Item"
        I18n.locale = :fr
        m.value
        -> "Objet"
        I18n.locale = :en_master
        m.value
        -> "Item"
        m.value = "Object"
        m.all_values
        -> {en: "Object", fr: "Objet"}

Build Status
------------

[![Build Status](http://travis-ci.org/TalentBox/sequel_bitemporal.png)](http://travis-ci.org/TalentBox/sequel_translatable)

License
-------

sequel_translatable is Copyright © 2011 TalentBox SA. It is free software, and may be redistributed under the terms specified in the LICENSE file.