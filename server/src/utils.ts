import { Request } from "express";

export function getSessionToken(req: Request): string | undefined {
    const authHeader = req.headers['authorization'];

    if (!authHeader) {
        return undefined;
    }

    const parts = authHeader.split(' ');

    if (parts.length !== 2 || parts[0] !== 'Bearer') {
        return undefined;
    }

    const sessionToken = parts[1];

    return sessionToken;
}