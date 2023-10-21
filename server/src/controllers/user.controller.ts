import express, { NextFunction, Request, Response, Router } from "express";
import { useTypeOrm } from "../database/typeorm";
import { User } from "../database/entities/user.entity";
import { getSessionToken } from "../utils";
import { Session } from "../database/entities/session.entity";
import { getGoogleUserInfo } from "./common";

const getSessionFromToken = async (req: Request) => {
    const session: Session | null = await useTypeOrm(Session).findOne({
        relations: {
            user: true
        },
        where: {
            sessionToken: getSessionToken(req)!,
            ip: req.ip,
        }
    });
    return session;
}

const getUserFromToken = async (req: Request) => {
    return (await getSessionFromToken(req))?.user;
}

const updateProfileUrl = async (userId: number) => {
    const { picture } = await getGoogleUserInfo(userId);
    if (picture) {
        const partial: Partial<User> = {
            id: userId,
            profileUrl: picture,
        };
        await useTypeOrm(User).save(partial);
    }
}

const controller = Router();


controller
    .use((req: Request, res: Response, next: NextFunction) => {
        if (!getSessionToken(req)) {
            res.status(400);
            res.send('provide a session token to access this path');
            return;
        }
        next();
    })
    .use(express.json())
    .get('/me', async (req: Request, res: Response) => {
        const session = await getSessionFromToken(req);

        if (!session) res.sendStatus(404);
        await updateProfileUrl(session!.user.id);

        res.send(session!.user);
    })
    .patch('/me', async (req: Request, res: Response) => {
        if (!req.body) {
            res.sendStatus(400);
            return;
        }
        const currentUser = await getUserFromToken(req);
        const newUser: Partial<User> = { ...req.body, id: currentUser?.id };

        const user = await useTypeOrm(User).save(newUser);
        await updateProfileUrl(user.id);
        res.send(user);
    })
    .get('/:id', async (req: Request, res: Response) => {
        const id = Number.parseInt(req.params.id);
        if (Number.isNaN(id)) {
            res.sendStatus(400);
            return;
        }
        await updateProfileUrl(id);
        const user = await useTypeOrm(User).findOneBy({ id });
        if (!user) {
            res.sendStatus(404);
        } else {
            res.send(user);
        }
    });

export default controller;