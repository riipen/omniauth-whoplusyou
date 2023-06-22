[![CircleCI](https://dl.circleci.com/status-badge/img/gh/riipen/omniauth-whoplusyou/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/riipen/omniauth-whoplusyou/tree/main)

# OmniAuth WhoPlusYou
Strategy to authenticate with WhoPlusYou via OAuth2 in OmniAuth.

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-whoplusyou'
```

Then `bundle install`.

## WhoPlusYou API Setup

Contact your WhoPlusYou instance administrator to be added access to the Developer Portal.

* Visit the API Keys page to find your Client ID and Client Secret.

* Set your Client Domains as needed with the exact redirect URI your application supports. Note that WhoPlusYou does not support any sort of wild card paths, so this must be an exact and full path to your reidrect URI.



## Usage
For additional information, refer to the [OmniAuth wiki](https://github.com/intridea/omniauth/wiki).

### Rails

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :whoplusyou, 
  		   ENV['WHOPLUSYOU_CLIENT_ID'], 
  		   ENV['WHOPLUSYOU_CLIENT_SECRET'],
  		   client_options: {
             site: 'https://myinstance.whoplusyou.com',
           },
           redirect_uri: Rails.application.routes.url_helpers.my_integration_response_url
end
```

You can now access the OmniAuth WhoPlusYou OAuth2 URL: `/auth/whoplusyou`

## Configuration

You can configure several options, which you pass in to the `provider` method via a hash:

* `scope`: A space-separated list of permissions you want to request from the user.

* `redirect_uri`: Override the redirect_uri used by the gem. Note this must match exactly what you specified in the WhoPlusYou Developer Portal in your Client Domains setting.

* `name`: The name of the strategy. The default name is `whoplusyou` but it can be changed to any value, for example `wpy`. The OmniAuth URL will thus change to `/auth/wpy` and the `provider` key in the auth hash will then return `wpy`.


## License

Copyright (C) 2023 Jordan Ell. See [LICENSE](https://github.com/riipen/omniauth-whoplusyou/blob/master/LICENSE.md) for details.
