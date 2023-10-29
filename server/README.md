# tictactoe server
An [express.js](https://expressjs.com/) server written in [Typescript](https://www.typescriptlang.org/) that manages the frontend's data.

This server requires [Node.js](https://nodejs.org/) and npm to run. It uses [Google's OAuth System](https://developers.google.com/identity/protocols/oauth2/web-server) for user authentication and [sqlite](https://sqlite.org/) for data storage.

## Configuration
1. Create a project on Google Cloud (if you don't have one already). This is required to get our client credentials.
2. Follow the steps given [here](https://developers.google.com/identity/protocols/oauth2/web-server#prerequisites) to create OAuth Authorization credentials. Add the necessary redirect URIs (if you are running this server on your machine, add `http://localhost:port` to the URI list, `port` is the port that the server will be listening on).
3. Download the `client_secrets.json` file and place it in the `src` directory.
4. Create a `.env` file based on the existing `.env.example` file and change the values of the variables if needed. The `PORT` variable should be used in the redirect URIs list in step 2.

## Running the server
1. Run `npm i`
2. Make sure `client_secrets.json` and `.env` are in the `src` and current directories respectively.
3. Run `npm start` to start the server.