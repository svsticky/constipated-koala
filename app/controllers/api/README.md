# Oauth endpoint
This folder is where the complex response format are depicted. Currently the following models are supported;

- Members
- Activities
- Participants
- Groups
- Checkout

## OAuth basics
Before working with oauth2 we need to set some basic ground rules. Koala allows Authorization Code Grant Flow and the Client Credentials Grant Flow. You are more likely to implement the first one than the latter one. Below the two grants are described.

> All traffic must be encrypted using SSL and the `client_secret` and `access_token` must never be on the users computer. Hence use sessions to store the access_token in your app. If you let others have access to this token or secret they can easily get access to your users data.

```shell
# create application using rake
$ bundle exec rake "doorkeeper:create[Postman application, urn:ietf:wg:oauth:2.0:oob, member-read participant-read participant-write]"
```

### Authorization Code
When a user in your app wants information or if you app need a authenticated user we use this variant. Your app sends the user to a login form of koala, there the user can login (if not already) and grant rights to your application(client). Koala will redirect the user back to your app with a one time code.
```
GET /api/oauth/authorize?client_id=d132e6e69dab381e39d3a14d6679b53444a83ddde4461db66013342e379c5110&redirect_uri=https://awesome.app/sign_in&response_type=code
```
```
{
  "code": "d247cf659f1076a9b2047e7711ad2f0b6b2b086944b02f4e13670a5d611a5d4f"
}
```


Your app performs a post request with your `client_id`, `client_secret`, and the `authorization code`, at Sticky this usually be a request on the server itself. This returns an json or xml object with information about the user and more importantly an `access_token`. All request to the api will be authorized by this `access_token` which will expire after a fixed time `expires_in`.
```
POST /api/oauth/token
{
  "grant_type": "authorization_code",
  "code": "d247cf659f1076a9b2047e7711ad2f0b6b2b086944b02f4e13670a5d611a5d4f",
  "client_id": "d132e6e69dab381e39d3a14d6679b53444a83ddde4461db66013342e379c5110",
  "client_secret": "822c1e42e82d921e3bbb03130cda60a607d1e63e6d705c9b5fa79aab5a683a2e",
  "redirect_uri": "https://awesome.app/specific-page"
}
```
```
{
  "access_token": "eb49949219182ce572529fec8be863af2c1847061de1db21e4304f615f66c04b",
  "token_type": "bearer",
  "expires_in": 14400,
  "refresh_token": "d247c9b2047e7711ad2f0b6b2b086944b02f4e1f659f1076a3670a5d611a5d4f",
  "scope": "member-read activity-read group-read",
  "created_at": 1446895075,
  "member": {
    "id": 1,
    "name": "Martijn Casteel",
    "email": "martijn.casteel@gmail.com"
  }
}
```
Note; a response can hold a `member` or an `admin` hash holding the same information.

### Client credentials
This flow of authentication is hardly used. It is only for the app itself. If your app wants to update their own informtion periodically, you can! But don't do it to often. Using this type of login you have limited number of resources, for example `birth_date` will be hidden.
```
POST /api/oauth/token
{
  "grant_type": "client_credentials",
  "client_id": "d132e6e69dab381e39d3a14d6679b53444a83ddde4461db66013342e379c5110",
  "client_secret": "822c1e42e82d921e3bbb03130cda60a607d1e63e6d705c9b5fa79aab5a683a2e"
}
```
```
{
  "access_token": "5e7bd08ef27d45c57952b1c62a13fbadf3eea313d341c1baf039765f7bb24fe0",
  "token_type": "bearer",
  "expires_in": 14400,
  "scope": "member-read activity-read group-read",
  "created_at": 1446895420
}
```

## Scopes
So now you know how to authenticate yourself, all the authorization is done in koala en depends on the scopes you request and the user accepts for your app. Before you can use koala as authenticator you need a `client_id` and `client_secret`. Also koala limits the scopes you can ask for, later more!

Ah well scopes, how do you create rights that are easily added or denied by the user itself; scopes. Koala has a number of scopes which are pretty self-explanatory;
- default  
  - member-read
  - activity-read
  - group-read
- optional
  - participant-read
  - participant-write
  - checkout-read
  - checkout-write

As said before your app can have limitations for example a book supplier has no interest in your activities or groups.
