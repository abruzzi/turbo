turbo
=====

![turbo](https://raw.githubusercontent.com/abruzzi/turbo/master/turbo.png)

Turbo is a easy to use tool for make the HTTP based API testing much more easier.  It can be used for testing `any` HTTP based service, like RESTFul API, or old school SOAP web service.

To get started, first install the gem `turbogenerator`

```sh
gem install turbogenerator
```

Have `turbo` installed, you can generate a `workflow` like this:

```sh
turbo generate myapi
```

then 

```sh
turbo start myapi
```

```sh
$ turbo start myrca
Scenario: posts, test cases: 2

Case: ['list posts'] passed
GET http://localhost:8080//api/feeds

Case: ['create posts'] failed
Expected: 200 OK
Got: HTTP/1.1 405 Method Not Allowed
Server: Apache-Coyote/1.1
Allow: GET, HEAD
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Fri, 10 Jul 2015 13:13:16 GMT


POST http://localhost:8080//api/fav-feeds
```