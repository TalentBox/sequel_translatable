# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "sequel_translatable"
  spec.version     = "0.3.0"
  spec.authors     = ["Joseph HALTER", "Koen De Hondt", "Jonathan Tron"]
  spec.email       = ["joseph.halter@thetalentbox.com", "koen@audacis.be", "jonathan@tron.name"]
  spec.homepage    = "https://github.com/TalentBox/sequel_translatable"
  spec.summary     = "Translate model attributes for sequel."
  spec.description = "Translate model attributes for sequel, fully tested."

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "i18n"
  spec.add_runtime_dependency "sequel"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
