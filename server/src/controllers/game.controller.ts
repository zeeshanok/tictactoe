import express, { Request, Response, Router } from "express";
import { getUserFromToken, requireSessionToken } from "./common";
import { useTypeOrm } from "../database/typeorm";
import { Game } from "../database/entities/game.entity";

const controller = Router();

controller

    .use(requireSessionToken())
    .use(express.json())
    .get('/', async (req: Request, res: Response) => {
        const user = await getUserFromToken(req);

        const games = await useTypeOrm(Game).find({
            where: [
                { playerO: user!.id.toString() },
                // or
                { playerX: user!.id.toString() },
            ]
        });

        res.send(games);
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

        await useTypeOrm(Game).save(game);
        res.sendStatus(200);
    });


export default controller;