import { NextFunction, Request, Response } from 'express';
import { google, Auth, oauth2_v2 } from 'googleapis';
import { web as secrets } from '../client_secret.json';
import { Session } from '../database/entities/session.entity';
import { useTypeOrm } from '../database/typeorm';
import { getSessionToken } from '../utils';
import { User } from '../database/entities/user.entity';

const users: { [id: number]: Auth.OAuth2Client; } = {};

export async function getGoogleUserInfo(userId: number): Promise<oauth2_v2.Schema$Userinfo>;
export async function getGoogleUserInfo(oauth: Auth.OAuth2Client): Promise<oauth2_v2.Schema$Userinfo>;
export async function getGoogleUserInfo(item: number | Auth.OAuth2Client): Promise<oauth2_v2.Schema$Userinfo> {
    const oauth = typeof item == 'number' ? users[item] : item;
    const { data } = await google.oauth2({
        auth: oauth,
        version: 'v2'
    }).userinfo.get();
    return data;
}


export async function getSessionFromToken(req: Request) {
    const session: Session | null = await useTypeOrm(Session).findOne({
        relations: { user: true },
        where: {
            sessionToken: getSessionToken(req)!,
            ip: req.ip,
        }
    });
    return session;
}


export async function getUserFromToken(req: Request) {
    return (await getSessionFromToken(req))?.user;
}

export async function getUserFromOAuthClient(oauth: Auth.OAuth2Client): Promise<User | null> {
    const data = await getGoogleUserInfo(oauth);
    if (!data.email) throw new Error("Did not get email from google api");
    return await getUserFromEmail(data.email);
}

export async function getUserFromEmail(email: string): Promise<User | null> {
    return await useTypeOrm(User).findOneBy({ email });
}

export async function getUserById(id: number) {
    return await useTypeOrm(User).findOneBy({ id });
}


export function getOAuthClient() {
    return new google.auth.OAuth2({
        clientId: secrets.client_id,
        clientSecret: secrets.client_secret,
        redirectUri: secrets.redirect_uris[0] + '/auth/callback'
    });
}


export function addOAuthUser(id: number, oauth: Auth.OAuth2Client) {
    console.log(`added user id ${id}`);
    users[id] = oauth;
}

/**
 * Middleware to verify sesion token in requests
 */
export function requireSessionToken() {
    return (req: Request, res: Response, next: NextFunction) => {
        if (!getSessionToken(req)) {
            console.log(`received request without session token (${req.path}), blocking...`);
            res.status(400);
            res.send('provide a session token to access this path');
            return;
        }
        next();
    };
}