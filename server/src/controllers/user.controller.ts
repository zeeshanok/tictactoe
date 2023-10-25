import express, { Request, Response, Router } from "express";
import { useTypeOrm } from "../database/typeorm";
import { User } from "../database/entities/user.entity";
import { getGoogleUserInfo, getSessionFromToken, getUserById, getUserFromToken, requireSessionToken } from "./common";

/**
 * Update profile url of a given user
 * @param userId id of the user who's profile url to update
 */
async function updateProfileUrl(userId: number) {
    const { picture } = await getGoogleUserInfo(userId);
    if (picture) {
        await useTypeOrm(User).update({ id: userId }, { profileUrl: picture });
    }
}

const controller = Router();


controller
    .use(requireSessionToken())
    .use(express.json())
    .get('/me', async (req: Request, res: Response) => {
        const session = await getSessionFromToken(req);
        if (!session) res.sendStatus(404);
        await updateProfileUrl(session!.user.id);

        res.send(session!.user);
    })
    .patch('/me', async (req: Request, res: Response) => {
        if (!req.body) {
            res.status(400);
            res.send('provide parameters to edit user');
            return;
        }
        const currentUser = await getUserFromToken(req);
        const edit: Partial<User> = { ...req.body };
        if (edit.username !== undefined && (edit.username === null || edit.username === '')) {
            res.status(400);
            res.send('Username cannot be empty or null');
        }


        await useTypeOrm(User).update({ id: currentUser!.id }, edit);
        const user = await getUserById(currentUser!.id);
        res.send(user);
    })
    .get('/:id(\\d+)', async (req: Request, res: Response) => {
        const id = Number.parseInt(req.params.id);
        await updateProfileUrl(id);
        const user = await getUserById(id);
        if (!user) {
            res.sendStatus(404);
        } else {
            res.send(user);
        }
    })
    .get('/exists', async (req: Request, res: Response) => {
        const username = req.query.username as (string | undefined);
        if (!username) {
            res.sendStatus(404);
        } else {
            const user = await useTypeOrm(User).findOneBy({ username });
            res.send({ exists: Boolean(user) });
        }
    });

export default controller;