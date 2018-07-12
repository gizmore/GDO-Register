
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "GDO-Register"
  spec.version       = 1.00
  spec.authors       = ["gizmore"]
  spec.email         = ["gizmore@wechall.net"]

  spec.summary       = %q{Signup module for GDO(Ruby)}
  spec.homepage      = "https://github.com/gizmore/GDO-Register"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug", "~> 10.0"

  spec.add_dependency "GDO", "~> 1"

end
