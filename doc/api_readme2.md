# API documentation
Koala has an API endpoint for a few applications; radio, _zuil_, and checkout, but there are many more possibilities. This documentation describes the possible routes and responses divided in; [members](#members), [groups](#groups), [activities](#activities), [participants](#participants), and [checkout](#checkout).

## Members

## Groups

## Activities
Activities are used by radio and the _zuil_ and radio also shows commercials of companies. These routes are publically available, however authenticating with the `activity-read` rights gives you more information about the activities.

##### Retrieve activities with posters
<pre>
<b>GET /api/activities HTTP/1.1</b>
Host → koala.svsticky.nl
</pre>

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8

[
  {
    "name": "Bord- en Kaartspellenavond",
    "start_date": "2016-02-08",
    "end_date": null,
    "poster": "https://koala.svsticky.nl/images/activities/195/medium.png?1453461841"
  },
  {
    "name": "Git Workshop",
    "start_date": "2016-02-16",
    "end_date": "2016-02-19",
    "poster": "https://koala.svsticky.nl/images/activities/196/medium.png?1453679092"
  }
]
```

##### Retrieve advertisements
<pre>
<b>GET /api/advertisements HTTP/1.1</b>
Host → koala.svsticky.nl
</pre>

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8

[
  {
    "poster": "https://koala.svsticky.nl/images/activities/199/medium.png?1453823170"
  }
]
```

## Participant


## Checkout
All checkout endpoints require a secret called `token` declared in the configuration of [.rbenv-vars](/.rbenv-vars-sample). A generic response because of this would be a forbidden response meaning that the secret does not correspond with the secret of koala.
```json
HTTP/1.1 403 FORBIDDEN
Content-Type → application/json; charset=utf-8
```
Below are the endpoints that can be used for checkout.



##### Retrieve products
<pre>
<b>GET /api/checkout/products HTTP/1.1</b>
Host → koala.svsticky.nl

+ <b>token</b>          :string <em>(required)</em>
</pre>

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8

[
  {
    "id": 98,
    "name": "7up",
    "category": 1,
    "price": "0.4",
    "image": "https://koala.svsticky.nl/images/checkout_products/7/original.png?1433681363"
  },
  {
    "id": 100,
    "name": "Coca Cola regular",
    "category": 1,
    "price": "0.53",
    "image": "https://koala.svsticky.nl/images/checkout_products/1/original.png?1433681225"
  }
]
```



##### Information for card
<pre>
<b>GET /api/checkout/card HTTP/1.1</b>
Host → koala.svsticky.nl

+ <b>token</b>          :string <em>(required)</em>
+ <b>uuid</b>           :string <em>(required)</em> - unique identifier of the OV-card
</pre>

```json
HTTP/1.1 200 OK
Content-Type → application/json; charset=utf-8

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
```



##### Create a new card and add to member
<pre>
<b>POST /api/checkout/card HTTP/1.1</b>
Host → koala.svsticky.nl

+ <b>token</b>          :string <em>(required)</em>
+ <b>student</b>        :string <em>(required)</em> - student id as known by koala
+ <b>uuid</b>           :string <em>(required)</em>
+ <b>description</b>    :string
</pre>

```json
HTTP/1.1 201 CREATED
Content-Type → application/json; charset=utf-8

{
  "id": 9,
  "uuid": "EDD411C4",
  "first_name": "Martijn",
  "balance": "0.0"
}
```

```json
# Student could not be found, make sure the student id is correct
HTTP/1.1 404 NOT FOUND
Content-Type → application/json; charset=utf-8
```

```json
# This uuid is already registered to some student
HTTP/1.1 409 CONFLICT
Content-Type → application/json; charset=utf-8
```



##### Create a new transaction
<pre>
<b>POST /api/checkout/transaction HTTP/1.1</b>
Host → koala.svsticky.nl

+ <b>token</b>          :string <em>(required)</em>
+ <b>uuid</b>           :string <em>(required)</em>
+ <b>items</b>          :array  <em>(required)</em> - array with item ids
</pre>

```json
HTTP/1.1 201 CREATED
Content-Type → application/json; charset=utf-8

{
  "uuid": "EDD411C4",
  "first_name": "Martijn",
  "balance": "0.9",
  "created_at": "2016-02-06T10:33:50.382+01:00"
}
```

```json
# Card is not yet activated
HTTP/1.1 401 UNAUTHORIZED
Content-Type → application/json; charset=utf-8
```

```json
# One of the items in your array is not found or
# there is no card with the specified uuid
HTTP/1.1 404 NOT FOUND
Content-Type → application/json; charset=utf-8
```

```json
HTTP/1.1 413 REQUEST ENTITY TOO LARGE
Content-Type → application/json; charset=utf-8

{
  "message": "insufficient funds",
  "balance": "2.9",
  "items": [
    1,
    2,
    2
  ],
  "costs": "-4.6"
}
```

```json
# Not allowed to buy alcohol at the moment
HTTP/1.1 406 NOT ACCEPTABLE
Content-Type → application/json; charset=utf-8

{
  "message": "alcohol allowed at 16:00"
}
```
