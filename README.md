# NetLinx Workspace

netlinx-workspace

A library for working with AMX NetLinx Studio workspaces in Ruby.

[![Gem Version](https://badge.fury.io/rb/netlinx-workspace.png)](http://badge.fury.io/rb/netlinx-workspace)
[![API Documentation](https://img.shields.io/badge/docs-api-blue.svg)](http://www.rubydoc.info/gems/netlinx-workspace)
[![Apache 2.0 License](https://img.shields.io/badge/license-Apache%202.0-yellowgreen.svg)](http://www.apache.org/licenses/LICENSE-2.0)

This library provides a developer API for working with NetLinx Studio workspaces
in Ruby. It also adds compiler support to the [NetLinx Compile](https://sourceforge.net/p/netlinx-compile/wiki/Home/)
gem for these workspaces.

**APW Target Version**

This library targets NetLinx .apw version `4.0` (created by NetLinx Studio 4).


## Issues, Bugs, Feature Requests

Any bugs and feature requests should be reported on the GitHub issue tracker:

https://github.com/amclain/netlinx-workspace/issues


**Pull requests are preferred via GitHub.**

Mercurial users can use [Hg-Git](http://hg-git.github.io/) to interact with
GitHub repositories.


## Installation

netlinx-workspace is available as a Ruby gem.

1. Install [Ruby](https://www.ruby-lang.org) 2.0.0 or higher.
    * Windows: Use [RubyInstaller](http://rubyinstaller.org/downloads/)
        and make sure ruby/bin is in your [system path](http://www.computerhope.com/issues/ch000549.htm).
    * Linux: Use [rbenv](https://github.com/sstephenson/rbenv#basic-github-checkout).
    
2. Open the [command line](http://www.addictivetips.com/windows-tips/windows-7-elevated-command-prompt-in-context-menu/)
    and type:
    
```
    gem install netlinx-workspace
    gem install netlinx-compile (optional for compiler support)
```


## Usage

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
file from a `workspace.config.yaml` text file. The advantage of using [YAML](http://yaml.org/spec/1.1/#id857168)
is that a workspace can easily be defined and maintained without the use of a
proprietary GUI editor. This means developers are free to use whichever text
editor they please, like [sublime-netlinx](https://github.com/amclain/sublime-netlinx),
to maintain a NetLinx workspace. Automated tools can generate, maintain, and
analyze this file as well.

To generate a template workspace config file, execute `netlinx-workspace --create`.

```yaml
systems:
  -
    name: Client - Room
    connection: 192.168.1.2
    touch_panels:
      -
        path: Touch Panel.TP4
        dps:  10001:1:0
    ir:
      -
        path: IR.irl
        dps:  5001:1:0
```


### Directory Structure

In order to simplify the configuration file, assumptions are made as to where
project files are located:

```text
include/
ir/
module/
touch_panel/
system_name.axs
workspace.config.yaml
```

The `include` directory is automatically scanned for `.axi` files, and the
`module` directory is scanned for `.tko` and `.jar` files. `.axs` modules are
ignored, as they should be tested and compiled independently before being
included in a project. However, it is encouraged to place the `.axs` module
source code file in the module directory as a courtesy so that other developers
can fix bugs and make updates if necessary.

Since touch panel and IR files can have a device address (DPS) attached, these
files are explicitly listed in the system. Multiple addresses can be defined
by using a YAML array.

```yaml
ir:
  -
    path: Cable Box.irl
    dps: ['5001:5:0', '5001:6:0', '5001:7:0', '5001:8:0']
```

In the case of multiple systems, the root directory of each system may need to
be offset from the workspace directory. This can be achieved by using the `root`
key.

```yaml
systems:
  -
    name: Room 101
    root: room_101
    connection: 192.168.1.2
    touch_panels:
      - path: Room_101.TP4
        dps:  10001:1:1
  -
    name: Room 201
    root: room_201
    connection: 192.168.1.3
    touch_panels:
      - path: Room_201.TP4
        dps:  10002:1:2
```

```text
room_101/include/
room_101/ir/
room_101/module/
room_101/touch_panel/
room_101/Room 101.axs

room_201/include/
room_201/ir/
room_201/module/
room_201/touch_panel/
room_201/Room 201.axs

workspace.config.yaml
```


### Connection Settings

The `connection` key supports a variety of options for configuring a system's
connection to the master controller:

```yaml
# IP address. Default ICSLan port 1319 is used.
connection: 192.168.1.2

# IP address with specific ICSLan port number.
connection: 192.168.1.2:1234

# IP address with specific ICSLan port number.
connection:
  host: 192.168.1.2
  port: 1234

# Serial port. Default baud rate 38,400 is used.
connection: COM2

# Serial port with baud rate.
connection: COM2:57600

# Serial port with multiple port settings.
connection:
  port: com2
  baud_rate: 115200
  data_bits: 7
  parity: even
  stop_bits: 2
```


### Additional Information

Examples of workspace configuration files can be found in the
[spec\workspace\yaml](https://github.com/amclain/netlinx-workspace/tree/master/spec/workspace/yaml)
directory of this library. These files show all of the keywords that are
available.
