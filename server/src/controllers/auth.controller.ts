import express, { Request, Response, Router } from "express";
import { randomBytes } from 'crypto';
import { Credentials } from 'google-auth-library';
import { User } from "../database/entities/user.entity";
import { useTypeOrm } from "../database/typeorm";
import { Session } from "../database/entities/session.entity";
import { addOAuthUser, getGoogleUserInfo, getOAuthClient, getSessionFromToken, getUserFromOAuthClient } from "./common";
import { getSessionToken } from "../utils";

const controller = Router();

/**
 * @returns session token
 */
function generateSessionToken() {
    return randomBytes(32).toString('hex');
}

/**
 * Creates a new session in the database
 * @param user the user to attach this session to
 * @param ip ip address of the user
 * @param oauthCredential OAuth credentials of the user (access token, refresh token etc.)
 * @returns the newly created session (without its id)
 */
async function createSession(user: User, ip: string, oauthCredential: Credentials) {

    const session = new Session();

    session.ip = ip;
    session.sessionToken = generateSessionToken();
    session.accessToken = oauthCredential.access_token!;
    session.refreshToken = oauthCredential.refresh_token as (string | undefined);
    session.user = user as User;
    await useTypeOrm(Session).upsert(session, ['user']);
    return session;
}

/**
 * Creates a new user in the database
 * @param email email of the user
 * @param profileUrl profile url of the user
 * @returns the newly created user
 */
async function createUser(email: string, profileUrl?: string): Promise<User> {
    const user = new User();
    user.email = email;
    if (profileUrl) user.profileUrl = profileUrl;
    return await useTypeOrm(User).save(user);
}

const accessScopes = ['email', 'profile', 'openid'];

controller

    // Get the redirect to Google's OAuth flow
    .get('/', async (req: Request, res: Response) => {
        const client = getOAuthClient();
        const authUrl = client.generateAuthUrl({
            access_type: 'offline',
            scope: accessScopes,
            state: req.query.redirect as (string | undefined),
        });

        res.redirect(301, authUrl);
    })
    // Signing in with a session token
    .post('/', async (req: Request, res: Response) => {
        const session = await getSessionFromToken(req);

        if (session) {
            const client = getOAuthClient();
            client.setCredentials({
                access_token: session.accessToken,
                refresh_token: session.refreshToken,
            });
            addOAuthUser(session.user.id, client);
            res.sendStatus(200);
        } else {
            res.sendStatus(404);
        }

    })
    // This is equivalent to signing out
    .delete('/', async (req: Request, res: Response) => {
        const sessionToken = getSessionToken(req);
        if (sessionToken) {
            await useTypeOrm(Session).delete({ sessionToken, ip: req.ip as string });
            res.sendStatus(200);
        } else {
            res.sendStatus(404);
        }
    })
    // After completing Google's OAuth flow the user is redirected to this endpoint
    .get('/callback', async (req: Request, res: Response) => {
        const client = getOAuthClient();
        if (!req.query.code) {
            res.status(400);
            res.send("no auth code was provided");
            return;
        }

        const { tokens } = await client.getToken(req.query.code as string);
        client.setCredentials(tokens);

        const data = await getGoogleUserInfo(client);

        // we should ideally have access to the email
        if (!data.email) res.sendStatus(500);

        let user = await useTypeOrm(User).findOneBy({ email: data.email! });
        let session: Session;
        if (user) {
            // creating a new session for this user
            console.log(`creating a new session for user: ${data.email}`);
            session = await createSession(user, req.ip!, tokens);
        } else {
            // create the user first then the session
            console.log('creating new user and session');
            user = await createUser(data.email!, data.picture ?? undefined);
            session = await createSession(user, req.ip!, tokens);
        }

        addOAuthUser(user.id, client);

        res.redirect(
            encodeURI(`http://localhost:8080/?session_token=${session.sessionToken}`)
        );
    })
    // endpoint for directly supplying an access and refresh token
    .post('/direct', express.json(), async (req: Request, res: Response) => {
        try {
            const client = getOAuthClient();
            const token = { access_token: req.body.access_token };
            client.setCredentials(token);

            let user = await getUserFromOAuthClient(client);
            if (!user) {
                const { email, picture } = await getGoogleUserInfo(client);
                user = await createUser(email!, picture ?? undefined);
            }
            console.log(`creating new session for ${user.email}`);
            const session = await createSession(user, req.ip as string, token);

            addOAuthUser(user.id, client);

            res.send({ sessionToken: session.sessionToken });
        } catch (e) {
            console.error(e);
            res.status(400);
            res.send('access code was not provided');
            return;
        }
    });

export default controller;