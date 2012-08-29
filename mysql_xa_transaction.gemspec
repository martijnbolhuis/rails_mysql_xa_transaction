$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mysql_xa_transaction/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mysql_xa_transaction"
  s.version     = MysqlXaTransaction::VERSION
  s.authors     = ["Martijn Bolhuis"]
  s.email       = ["gumbo.mcgee@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Enable transactions over multiple MySql database connections (distributed XA transactions)"
  s.description = "TODO: Description of MysqlXaTransaction."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "sqlite3"
end
