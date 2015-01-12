turbo
=====

Turbo is simple wrapper of curl for RESTful API testing.

```sh
gem install turbo
```

```sh
turbo generate your_workflow
```

```sh
turbo start your_workflow
```

```sh
turbo start myrca
curl -is -H "Accept: application/json" -H "Content-Type: application/json" -X GET  http://localhost:12306/users -D - -o debug.log
HTTP/1.1 200 OK
Success: curl -is -H "Accept: application/json" -H "Content-Type: application/json" -X GET  http://localhost:12306/users -D - -o debug.log

curl -is -H "Accept: application/json" -H "Content-Type: application/json" -X GET  http://localhost:12306/userinfo -D - -o debug.log
Error: curl -is -H "Accept: application/json" -H "Content-Type: application/json" -X GET  http://localhost:12306/userinfo -D - -o debug.log
```
起一个端口：
python -m SimpleHTTPServer 9527

本地更改之后执行一下命令生成一个本地gem包

gem build turbo.gemspec

gem install localPath/turbogenerator-XXX.gem
