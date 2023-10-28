import express, { Request, Response, Router } from "express";
import { getUserFromToken, requireSessionToken } from "./common";
import { useTypeOrm } from "../database/typeorm";
import { Game } from "../database/entities/game.entity";
import { FindOptionsWhere } from "typeorm";

const maxGamesStoredPerUser = 20;

async function addGame(game: Partial<Game>) {
    await useTypeOrm(Game).save(game);
}
async function getGamesByUserId(userId: number, options?: FindOptionsWhere<Game>[]) {
    const conditions = [
            { playerO: userId.toString() },
            // or
            { playerX: userId.toString() },
            ...(options ?? [])
        ];
        
    return await useTypeOrm(Game).find({
        where: conditions,
        order: { createdAt: 'DESC' }
    });
}

const controller = Router();

controller

    .use(requireSessionToken())
    .use(express.json())
    .get('/', async (req: Request, res: Response) => {
        const parsedId = Number.parseInt(req.query.userId as string);
        const id = Number.isNaN(parsedId) ? (await getUserFromToken(req))?.id : parsedId;
        if (id === undefined) {
            res.sendStatus(401);
            return;
        }
        const games = await getGamesByUserId(id);

        res.send({ games });
    })
    .get('/:id(\\d+)', async (req: Request, res: Response) => {
        const game = await useTypeOrm(Game).findOneBy({ id: Number.parseInt(req.params.id) });
        if (!game) {
            res.sendStatus(404);
        } else {
            res.send(game);
        }
    })
    // this endpoint is used for offline games only
    .post('/', async (req: Request, res: Response) => {
        if (!req.body) {
            res.status(400);
            res.send('provide a game to add');
            return;
        }
        const game: Partial<Game> = { ...req.body };

        if (game.type === 'online') {
            res.status(405);
            res.send('Online games cannot be added with this endpoint');
            return;
        }

        await addGame(game);

        res.sendStatus(200);
    })


setTimeout(() => { }, 1000 * 60);

export default controller;