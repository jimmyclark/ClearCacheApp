#!/usr/bin/ruby
# -*- coding: UTF-8 -*-

require "jwt"

# GS5HB4U44N.com.bigfoot.mixedtentha
# key_file = "/Users/amnon/devWorkspace/svn_workspaces/Bigfoot/dict/develop/tools/AuthKey_B8DDY3NWRT.p8"
key_file = "AuthKey_B8DDY3NWRT.p8"
team_id = "GS5HB4U44N"
client_id = "com.bigfoot.mixedtentha"
key_id = "B8DDY3NWRT"
validity_period = 180 # In days. Max 180 (6 months) according to Apple docs.

private_key = OpenSSL::PKey::EC.new IO.read key_file

token = JWT.encode(
  {
    iss: team_id,
    iat: Time.now.to_i,
    exp: Time.now.to_i + 86400 * validity_period,
    aud: "https://appleid.apple.com",
    sub: client_id
  },
  private_key,
  "ES256",
  header_fields=
  {
    kid: key_id
  }
)

puts token


# eyJraWQiOiJCOEREWTNOV1JUIiwiYWxnIjoiRVMyNTYifQ.eyJpc3MiOiJHUzVIQjRVNDROIiwiaWF0IjoxNTkxODUwMTcwLCJleHAiOjE2MDc0MDIxNzAsImF1ZCI6Imh0dHBzOi8vYXBwbGVpZC5hcHBsZS5jb20iLCJzdWIiOiJjb20uYmlnZm9vdC5taXhlZHRlbnRoYSJ9.3Gn7qa9cmceKWHsjLBcVTJcvTPK6VuOh3bSdoBzYbFymeFoEIP6VoV3hbKzzpWCbx1aqYa1cDzqGbUXfiUYsew
#
#
