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

## Participant