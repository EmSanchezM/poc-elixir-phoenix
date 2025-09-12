# POC Elixir Phoenix
Proof of concept for the basic features of Phoenix

## Getting started
* Checking install elixir `elixir --version`
* Checking install mix `mix --version`
* Install tool for phoenix cli `mix archive.install hex phx_new`
* Create a new project `mix phx.new <name_project>`
* Run a server `mix phx.server`

## Control flow
* Generate authentication very easy: `mix phx.gen.auth Accounts User users`
* Generate crud basic very easy:
    - Command: `mix phx.gen.live <Module> <Schema> <attributes:type>`
    - Example: `mix phx.gen.live Product products name:string price:decimal`