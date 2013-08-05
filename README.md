turbo
=====

a simple wrapper of curl for RESTful API testing


#### How to use?

Just run the script `test.sh`

So, basically, test.sh will launch the app.rb, which will initialize a Turbo:

-    read configuration from `turbo.conf`
-    run all the tests under `scenarios` folder if any
-    if the scenario contains testing data(which you may want to upload to server), they can be placed to `requests` folder

#### How it works?

Turbo is built on the top of `curl`, and try to make RESTFul testing more easier, it combine the `common.json` and your
test scenario (say, local-user-get.json) together, and translate them into a system call to curl like:

```
curl -X POST -d @requests/data.json -H "Accept: application/json" -o debug.log -D - http://under.testing/resources
```

and will try to search a pattern defined in `success` section in your scenario.

```
"success": "201 Created"
```

if the response contains "201 Created", that scenario will be marked as susccess.

#### Enhancement

Turbo was born today(Aug 5, 2013), so I may add a lot of new features in the following days.

But I dont want things go complex, maybe a few common curl options will be added and I'll try to make the `success` justice part 
more smart.
