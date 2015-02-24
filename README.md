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

### NetLinx Compile Support

Installing this gem automatically enables support for [NetLinx Compile](https://github.com/amclain/netlinx-compile)
to compile NetLinx Studio workspace (.apw) files.


### Rake Tasks

NetLinx Workspace comes with a set of rake tasks that can be used by adding
`require 'netlinx/rake/workspace'` to your project's Rakefile. Type
`rake --tasks` on the command line to view the available tasks.


### Command Line

`netlinx-workspace` is available from the command line; a list of options can
be displayed by executing `netlinx-workspace --help`.


### Ruby Developer API

A Ruby API is provided for developers looking to integrate the NetLinx Workspace
library into thier own tools. See the 
[NetLinx Workspace API documentation](http://rubydoc.info/gems/netlinx-workspace).


## YAML Workspace Configuration

NetLinx Workspace has the ability to generate a NetLinx Studio Workspace (.apw)
file from a `workspace.config.yaml` text file. The advantage to using [YAML](http://yaml.org/spec/1.1/#id857168)
is that a workspace can easily be defined and maintained without the use of a
proprietary GUI editor. This means developers are free to use whichever text
editor they please, like [sublime-netlinx](https://github.com/amclain/sublime-netlinx),
to maintain a NetLinx workspace. Automated tools can generate, maintain, and
analyze these files as well.

To generate a template workspace config file, type `netlinx-workspace --create`.

```yaml
systems:
  -
    name: Client - Room
    connection: 192.168.1.2
    touch_panels:
      -
        path: Touch Panel.TP4
        dps: '10001:1:0'
    ir:
      -
        path: IR.irl
        dps: '5001:1:0'
```
