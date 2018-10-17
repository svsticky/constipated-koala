Doorkeeper::OpenidConnect.configure do
  issuer 'http://koala.rails.local:3000'

  signing_key <<-EOL
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+sVp8NINl6qFd
aS4a9IxIhg0KxNchfj3f3nAVtYcDASP2hgnZfC2sjCB07Nnzcy2B/2zN37iQABzO
J8+dU9yw55bGMNxNIz2l/mV7KP1pwTOb3ynXH2EUnZ4Mwv5P95B/mu79jwEsLKV3
Qf2S+HKPvnXAhvy3dau6Q87ul2EPx0HaA1MzeWkD8T+kUlCfU8iOk1aX3SBhqht5
6ez11kxr4blnH1DA5pYPj9Hc+j0++eKuMs61BquLMrasQWkmQK/TDvbnI2w2hcwY
Tb0V6dDqdTW0jp3BJGzkiCTcTTGYnnFfI9DfQS6/dlQeQqn9Q12R3ua8YlcldRzo
cb64+WJpAgMBAAECggEAYoT4jcEHvejps3v60PxVWcbACDdIOkqhpv6iA+VEOp4l
OWFox08rvcCrqB0SQX/ZHBed3ANgtC0KtMvGrK6+DzunHv/xYXz6hb8YKPg1bKTf
iAFU+YqBuofwNwGrKB9sLTEbli6C2ZK7bhDO9FadwXwSFATpndMShOoxh/z3rZFN
OSojjgbnP35gCIu8nlcUbKlxSg6S4wRqxN7CjfXwbPaftXGQSUdybAXSHyvAwyyK
4gdCTJYvd+Vyv5c7hY5NsshuLaT+67mGppLU1AeDn1ktBqKE/qJycC/6IlmHrQ9m
5n6haIjR3cM1FLcq6iHkxwh5g/qmZTH2TtY0FWpFsQKBgQDfEAT2WT39cXF5zEZ0
E8DkRiZqC+bccDpwjVcqHSdDnAwrnYC0QqG85lvcN4wfa13wSwLgVCMYb4pr0Xwy
SgmwD0mPAlTfmDNc2YiAZPxOwI4IrNRUbIkP61U+pHITToiRiRcLQ0SvkvBXXPE+
MVOKnJnwT2+X0+seReq6OmfGPQKBgQDa2bmN5d1ayMu7W5UtzNkiDmuX+7vb4Tsu
tMNldTu1BjAsEGyRkbHPCoUAmCG3KNTyb6GVBsicztFlOepKnEwlBgZvsDhrHmnD
pTFI8rvtdaX4EYW2MHKtmq201hr2E6enX4QHU4WvESUyERMfh2Zgp6vcSNoUzyxx
BfKXvkP7nQKBgEzPMFY/3qex85g0LiJ0VtyEB2BG3uUTRBxTnysiRM30IwC1yIbJ
1vW8AO+wtPBwwTUoL0Jd1oPojKqZxQFwGyvj57l13RHtT+puAaHspDDd/0qfcLHt
ebjgmUbry1g4l7A9m5DGRhWLLHV4zJ1U0OaPDDcCs3N9hp2zB6O+ztMlAoGBALRd
VCu6EiBL9HxJEj1Y4mrK76mmckDY82me2Jq5b6fVncXzE0c1iBFWXh8LQl4tbLMR
hV3I5XU2jiSbApjTD35D5PIPja/atNflQSUZyAAAQfScnFJ2w0yIejjbbAT6VeX/
NlTDZR3PR5Rnthb6BEoMZft6nyEfTUUo3bJpwKWRAoGBALvygUnLMVGvllBWt4FW
JFcqcSu1Sc3XiOSJjWxQSuTpvMd+DPuJjQluuoEBl3qP0dv0NpLEOz7yj9Mnk+4e
DiX45FXehUj9lJ+atRIhDc5WDZzT0o3Q6/1R0XVDDsMUiqMSkaokS+iv3vjunlXj
14v88/lAYbkQm+Gw72FVnoau
-----END PRIVATE KEY-----
EOL

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find_by_id(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  subject do |resource_owner, application|
    resource_owner.id
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end
