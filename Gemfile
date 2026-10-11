source "https://rubygems.org"

# Specify your gem's dependencies in relaton_ieee.gemspec
gemspec

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"

gem "equivalent-xml", "~> 0.6"
gem "pry-byebug"
gem "ruby-jing"
gem "simplecov"
gem "vcr"
gem "webmock"
gem "webrick"

# TEMPORARY: the rubyzip ~> 3.7 constraint ships with relaton-index
# (relaton/relaton-index#23, merged to main); pin the dev resolution
# to main until the 0.2.23 release lands, then flip to released.
gem "relaton-index", github: "relaton/relaton-index", branch: "main"

# Current stack: the relaton monogem line (v3 train)
gem "relaton", "= 3.0.0.pre.alpha.11"
gem "relaton-render", "= 3.0.0.pre.alpha.19"
gem "pubid", github: "pubid/pubid", branch: "main"
gem "lutaml-model", "~> 0.8"
