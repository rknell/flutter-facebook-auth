# flutter_facebook_auth

Flutter plugin to make easy the facebook authentication in your flutter app. iOS and Android are supported.

## **install on Android**

Go to https://developers.facebook.com/docs/facebook-login/android/?locale=en and read the next documentation.

- Edit Your Resources and Manifest
- Associate Your Package Name and Default Class with Your App
- Provide the Development and Release Key Hashes for Your App
---
## **Install on iOS**

In your Podfile uncomment the next line (You need set the minimum target to 9.0 or higher)

```
platform :ios, '9.0'
```

Configure `Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb{your-app-id}</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>{your-app-id}</string>
<key>FacebookDisplayName</key>
<string>{your-app-name}</string>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
  <string>fbauth2</string>
  <string>fbshareextension</string>
</array>
```

## **On iOS you need Swift support**

The plugin is written in `Swift`, so your project needs to have Swift support enabled. If you've created the project using `flutter create -i swift [projectName]` you are all set. If not, you can enable Swift support by opening the project with XCode, then choose `File -> New -> File -> Swift File`. XCode will ask you if you wish to create Bridging Header, click yes.

---

## If you have implement another providers (Like Google) in your app you should merge values in Info.plist 

Check if you already have CFBundleURLTypes or LSApplicationQueriesSchemes keys in your Info.plist. If you have, you should merge their values, instead of adding a duplicate key.

Example with Google and Facebook implemetation:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb{your-app-id}</string>
      <string>com.googleusercontent.apps.{your-app-specific-url}</string>
    </array>
  </dict>
</array>
```


---
## NOTE
for Objective-C projects (correctly works is not granted because this plugin was written with swift)

---
### **METHODS**

Just use `FacebookAuth.instance`. NOTE: all methods are **asynchronous**.

- `.login({List<String> permissions = const ['email', 'public_profile'] })` : request login with a list of permissions.

  The `public_profile` permission allows you read the next fields
  `id, first_name, last_name, middle_name, name, name_format, picture, short_name`

  For more info go to https://developers.facebook.com/docs/facebook-login/permissions/

  return one instance of `LoginResult` class:

  ```
  {
    status: 200,
    accessToken: {
      expires: 1573493493209,
      declinedPermissions: [],
      grantedPermissions: [public_profile, email],
      userId: 3003332493073668,
      token: EAAVDwBAE5lndhpg17DHFZABzh6QKiAZC42Qljcub9gib52L5CPEXvhk2ZBEa7LlOuyastmmkZBfwP7dKW6Xi4tvrTw8DToO2M2kMcau6CXsYtyys7WZAWV3XaMPnhuVauo5ghtGpnhJvZAtMKqlsgbV5GklPAYZD
    }
  }
  ```

  if `status` is 200 the login was successfull.

- `.logOut()` : close the current facebook session.

- `.isLogged` : check if the user has an active facebook session. The response will be `null` if the user is not logged.
  return one instance of `AccessToken` class:
  ```
  {
      expires: 1573493493209,
      userId: 3003332493073668,
      token: EAATaHWA7VDwBAE5lndhpg17DHFZABzh6QKiAZC42Qljcub9gib52L5CPEXvhk2ZBEa7LlOuytmmkZBfwP7dKW6Xi4XCO2M2kMcau6CXsYtyys7WZAWV3XaMPnhuVauo5ghtGpnhJvZAtMKqlsgbV5GklPAYZD,
      declinedPermissions: [],
      grantedPermissions: [public_profile, email],
    }
  ```


- `.getUserData({String fields = "name,email,picture"})` : get the user info only if the user is logged.

  Expected response:

  ```
  {
  email = "dsmr.apps@gmail.com";
  id = 3003332493073668;
  name = "Darwin Morocho";
  picture =     {
      data =         {
          height = 50;
          "is_silhouette" = 0;
          url = "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=3003332493073668&height=50&width=50&ext=1570917120&hash=AeQMSBD5s4QdgLoh";
          width = 50;
      };
  };
  }
  ```

### **EXAMPLE**

```dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() => runApp(MyApp());

String prettyPrint(Map json) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic _userData;
  AccessToken _accessToken;
  bool _checking = true;

  String twitterStatus = "No Logged";

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  _printCredentials(LoginResult result) {
    _accessToken = result.accessToken;
    print("userId: ${result.accessToken.userId}");
    print("token: ${prettyPrint(_accessToken.toJson())}");
    print("expires: ${result.accessToken.expires}");
    print("grantedPermission: ${result.accessToken.grantedPermissions}");
    print("declinedPermissions: ${result.accessToken.declinedPermissions}");
  }

  _checkIfIsLogged() async {
    final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
      // now you can call to  FacebookAuth.instance.getUserData();
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields:"email,birthday");
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
      });
    }
  }

  _login() async {
    setState(() {
      _checking = true;
    });
    final result = await FacebookAuth.instance.login();
    // final result = await FacebookAuth.instance.login(permissions:['email','user_birthday']);

    _checking = false;
    switch (result.status) {
      case FacebookAuthLoginResponse.ok:
        _printCredentials(result);
        // get the user data
        final userData = await FacebookAuth.instance.getUserData();
        // final userData = await _fb.getUserData(fields:"email,birthday");
        _userData = userData;
        break;
      case FacebookAuthLoginResponse.cancelled:
        print("login cancelled");
        break;
      default:
        print("login failed");
    }

    setState(() {});
  }

  _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    setState(() {
      _userData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facebook Auth Example'),
        ),
        body: _checking
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _userData != null
                            ? prettyPrint(_userData)
                            : "NO LOGGED",
                      ),
                      SizedBox(height: 20),
                      _accessToken != null
                          ? Text(
                              prettyPrint(_accessToken.toJson()),
                            )
                          : Container(),
                      SizedBox(height: 20),
                      CupertinoButton(
                        color: Colors.blue,
                        child: Text(
                          _userData != null ? "LOGOUT" : "LOGIN",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _userData != null ? _logOut : _login,
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
```

## **Using with firebase_auth**

```dart
import 'package:firebase_auth/firebase_auth.dart';
.
.
.
.


final FirebaseAuth _auth = FirebaseAuth.instance;
.
.
.

 // this line do auth in firebase with your facebook credential. Just pass your facebook token (String)
 final OAuthCredential credential =  FacebookAuthProvider.credential( _accessToken.token); // _token is your facebook access token as a string

// FirebaseUser is deprecated
final User user = (await _auth.signInWithCredential(credential)).user;
```
