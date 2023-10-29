# tictactoe frontend

TicTacToe on steroids

## Running
1. Install [Flutter](https://flutter.dev)
2. Make sure your shell is in this directory (otherwise run `cd app`)
3. Use the `.env.example` file to create a similar `.env` file (this is required to connect to the server). The reason there are seperate variables for desktop and mobile versions of the app is because of how I tested this app on my phone. If you would like to test this app on your phone follow these [steps](#configuring-the-mobile-version-of-the-app-to-connect-to-a-serverconfiguring-the-mobile-version-of-the-app-to-connect-to-a-server).

### Environment variables
The following variables are to be defined in the `.env` file. The file should be placed in the same directory as the `.env.example` file:
|Variable|Description|Suggested value if you are hosting the server locally|
---------|-----------|-----------------|
`DESKTOP_SERVER_URL`|The url that the desktop version of the app should use to connect to the server.|`http://localhost:$port`
`MOBILE_SERVER_URL`|Same as above except its for the mobile version of the app|-
`DESKTOP_WEBSOCKET_URL`|The url that the desktop version of the app uses to connect to the websocket server|`ws://localhost:$websocket_port`
`DESKTOP_WEBSOCKET_URL`|Same as above except its for the mobile version of the app|-

The suggested values that were left blank in table above can be found by following the next steps.

### Configuring the mobile version of the app to connect to a server
Assuming your server is running on your local PC, we can connect the mobile app to the server by using the following steps (on Windows):
1. Turn on your phone's mobile hotspot.
2. Connect your PC to the hotspot.
3. On your PC, run `ipconfig /all` and find the IPv4 address that looks something like `x.x.x.x(Preferred)`
4. Use this IP address to fill up the blank values in the table above.

If you've followed all the steps above and you have the server running (instructions [here](../server/README.md)) you can start the app by running:
```ps
flutter run --release
```
