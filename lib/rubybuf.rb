require "rubygems"

gem "activesupport", ">= 2.2.2", "<3.0.pre"

require "delegate"
require "singleton"
require "time"
require "validatable"
require "active_support/callbacks"
require "active_support/core_ext"
require "active_support/time_with_zone"
require "will_paginate/collection"

require "rubybuf/base128"