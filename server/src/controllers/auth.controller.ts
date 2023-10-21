import { Request, Response, Router } from "express";
import { randomBytes } from 'crypto';
import {Credentials} from 'google-auth-library';
import { User } from "../database/entities/user.entity";
import { useTypeOrm } from "../database/typeorm";
import { Session } from "../database/entities/session.entity";
import { addOAuthUser, getGoogleUserInfo, getOAuthClient } from "./common";

const controller = Router();
const generateSessionToken = () => randomBytes(32).toString('hex');

const createSession = async (user: User, ip: string, oauthCredential: Credentials) => {
    const session = new Session();
    session.ip = ip;
    session.sessionToken = generateSessionToken();
    session.accessToken = oauthCredential.access_token!;
    session.expiryTime = oauthCredential.expiry_date!;
    session.refreshToken = oauthCredential.refresh_token!;
    session.user = user as User;
    return await useTypeOrm(Session).save(session);
};

const createUser = async (email: string, profileUrl?: string): Promise<User> => {
    const user = new User();
    user.email = email;
    if (profileUrl) user.profileUrl = profileUrl;
    return await useTypeOrm(User).save(user);
};

const accessScopes = ['email', 'profile', 'openid'];

controller

    .post('/', async (req: Request, res: Response) => {
        const session = await useTypeOrm(Session).findOne({
            relations: { user: true },
        });

        if (session) {
            const client = getOAuthClient();
            client.setCredentials({
                access_token: session.accessToken,
                refresh_token: session.refreshToken,
            })
            addOAuthUser(session.user.id, client);
            res.sendStatus(200);
            return;
        }

        const client = getOAuthClient();
        const authUrl = client.generateAuthUrl({
            access_type: 'offline',
            scope: accessScopes,
        });

        res.redirect(301, authUrl);
    })
    .get('/callback', async (req: Request, res: Response) => {
        const client = getOAuthClient();
        if (!req.query.code) {
            res.sendStatus(400);
            return;
        }

        const { tokens } = await client.getToken(req.query.code as string);
        client.setCredentials(tokens);

        const data = await getGoogleUserInfo(client);

        if (!data.email) res.sendStatus(500);

        let user = await useTypeOrm(User).findOneBy({ email: data.email! });
        let session: Session;
        if (user) {
            // creating a new session for this user
            session = await createSession(user, req.ip!, tokens);
        } else {
            // create the user first then the session
            user = await createUser(data.email!, data.picture ?? undefined);
            session = await createSession(user, req.ip!, tokens);
        }

        addOAuthUser(user.id, client);

        res.json({
            session_token: session.sessionToken
        });
    });

export default controller;