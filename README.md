# NetLinx Workspace

netlinx-workspace

A library for working with AMX NetLinx Studio workspaces in Ruby.

[![Gem Version](https://badge.fury.io/rb/netlinx-workspace.png)](http://badge.fury.io/rb/netlinx-workspace)
[![API Documentation](https://img.shields.io/badge/docs-api-blue.svg)](http://www.rubydoc.info/gems/netlinx-workspace)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-yellowgreen.svg)](http://www.apache.org/licenses/LICENSE-2.0)

This library provides a developer API for working with NetLinx Studio workspaces
in Ruby. It also adds compiler support to the [NetLinx Compile](https://sourceforge.net/p/netlinx-compile/wiki/Home/)
gem for these workspaces.


## Installation

netlinx-workspace is available as a Ruby gem.

1. Install [Ruby](http://www.ruby-lang.org/en/downloads/) v2.0 or greater.
(For Windows use [RubyInstaller](http://rubyinstaller.org/) and make sure
ruby/bin is in your [system path](http://www.computerhope.com/issues/ch000549.htm).)

2. Open the [command line](http://www.addictivetips.com/windows-tips/windows-7-elevated-command-prompt-in-context-menu/)
and type:
```
    gem install netlinx-workspace
    gem install netlinx-compile (optional for compiler support)
```


## Use

**NetLinx Compile Support**

Installing this gem automatically enables support for NetLinx Compile to compile
NetLinx Studio workspace (.apw) files.


**Ruby Developer API**

A Ruby API is provided for developers looking to integrate the NetLinx Workspace
library into thier own tools.
[NetLinx Workspace API Documentation](http://rubydoc.info/gems/netlinx-workspace)


## Status

This tool is known to be stable when integrated with netlinx-compile.
API features are still in development.
