import { google, Auth } from 'googleapis';
import { web as secrets } from '../client_secret.json';

const users: { [id: number]: Auth.OAuth2Client; } = {};

export async function getGoogleUserInfo(item: number | Auth.OAuth2Client) {
    const oauth = typeof item == 'number' ? users[item] : item;
    const { data } = await google.oauth2({
        auth: oauth,
        version: 'v2'
    }).userinfo.get();
    return data;
}




export const getOAuthClient = () => new google.auth.OAuth2({
    clientId: secrets.client_id,
    clientSecret: secrets.client_secret,
    redirectUri: secrets.redirect_uris[0] + '/auth/callback'
});

export const addOAuthUser = (id: number, oauth: Auth.OAuth2Client) => {
    console.log(`added user id ${id}`);
    users[id] = oauth;
};