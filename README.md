# S2S::Auth

This gem creates a S2S authentication header to make S2S API requests.
S2S header format: Bearer <token>

## Installation

Add this line to your application's Gemfile:

    gem 's2s-auth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s2s-auth

## Usage

You need to setup the gem by setting four values:

* app name
* internal secret
* secret salt
* sign salt

```ruby
# setup
S2S::Auth.setup({secret: "this is my secret",
    app: "test",
    salt: "f7b5763636f4c1f3ff4bd444eacccca2",
    sign_salt: "95d87b990cc104124017ad70550edcfd22b8e89465338254e0b608592a9aac29"
})

# generate http authorization header
S2S::Auth.header
# => {:Authorization=>"Bearer bUcweFFKcUpCcWxPQTczcjZTMm1yYkxBL3RDUFk1L2xKVVY4VjU2R1EwbkExTE00eUI0RkxmNzFwbWM4WS8waS0tQ1hiUWVMZ0FwVVZCOGVqQVc5cFJGQT09--afa1f7353e789cc8fc1a332b0c355fb07a7efb03"}

# generate just the token
S2S::Auth.generate_token
# => "TWRsNE16ZzR3dG9qVjcwKzlEc1B4R0h4UGwyTHcyVTlRZ0szV0EybE1jV3R6VjF1WHpPSnNDcjRaRVdIeGFlYS0tT3FqQktYbmU2cVpvVzdTZzM3ditMdz09--09144f0202ef708622ac8d778cc062f5d62c22a3"

# parse the token
S2S::Auth.parse_token(S2S::Auth.generate_token)
# => {"app"=>"test", "ts"=>"2014-02-11T06:33:39Z"}
```
