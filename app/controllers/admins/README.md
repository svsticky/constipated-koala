#API documentation
Koala has an API endpoint for a few applications; radio, _zuil_, and checkout. This documentation describes the possible routes and responses. 

## Activities


## Checkout
All checkout endpoints require a `secret` called token declared in the configuration of [.rbenv-vars-sample](/.rbenv-vars-sample). A generic response because of this would be a forbidden response meaning that the secret does not correspond with the secret of koala.
```json
HTTP/1.1 403 FORBIDDEN
Content-Type → application/json; charset=utf-8
Content-Encoding → gzip
```
Below are the other action that can be used for checkout.

##### Retrieve products
<pre>
<b>GET /api/checkout/products HTTP/1.1</b>
Host: koala.svsticky.nl
Cache-Control: no-cache

+ <b>token:</b> String (required)
</pre>

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8
Content-Encoding → gzip

[
  {
    "id": 98,
    "name": "7up",
    "category": 1,
    "price": "0.4",
    "image": "https://sticky-posters.s3.amazonaws.com/checkout_products/7?1433681363"
  },
  {
    "id": 100,
    "name": "Coca Cola regular",
    "category": 1,
    "price": "0.53",
    "image": "https://sticky-posters.s3.amazonaws.com/checkout_products/1?1433681225"
  }
]
```

##### Information for card
<pre>
<b>GET /api/checkout/card HTTP/1.1</b>
Host: koala.svsticky.nl
Cache-Control: no-cache

+ <b>token:</b> String (required)
+ <b>uuid:</b>  String (required)
</pre>
Where `uuid` is the unique identifier of the card, for now we only support OV-chipcards

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8
Content-Encoding → gzip

{
  "id": 9,
  "uuid": "EDD411C4",
  "first_name": "Martijn",
  "balance": "4.15"
}
```

```json
# card with that specific uuid not found
HTTP/1.1 404 NOT FOUND
Content-Type → application/json; charset=utf-8
Content-Encoding → gzip
```

