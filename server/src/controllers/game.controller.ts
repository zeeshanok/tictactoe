import express, { Request, Response, Router } from "express";
import { addGame, getGamesByUserId, getUserFromToken, requireSessionToken } from "./common";
import { useTypeOrm } from "../database/typeorm";
import { Game } from "../database/entities/game.entity";
import { And, Brackets } from "typeorm";
import { Star } from "../database/entities/star.entity";

async function toggleStar(starred: boolean, gameId: number, userId: number) {
    const options = { game: { id: gameId }, user: { id: userId } };
    if (starred) {
        await useTypeOrm(Star).createQueryBuilder("star")
            .insert()
            .orIgnore()
            .into(Star)
            .values(options)
            .execute();
    } else {
        await useTypeOrm(Star).delete(options);
    }
    // return await useTypeOrm(Game)
    //     .createQueryBuilder("game")
    //     .update(Game)
    //     .set({ starred })
    //     .where("game.id = :gameId", { gameId })
    //     .andWhere(new Brackets((qb) =>
    //         qb
    //             .where("game.playerX = :userId", { userId })
    //             .orWhere("game.playerO = :userId", { userId }))
    //     )
    //     .execute();
}


/**
 * Produces a route handler that can either perform a star or unstar operation
 * on a game
 * @param starred whether the route handle should star or unstar
 * @returns the route handler
 */
function createStarRoute(starred: boolean) {
    return async (req: Request, res: Response) => {
        const { id } = req.params;
        const user = await getUserFromToken(req);
        if (!user) res.sendStatus(401);
        else {
            await toggleStar(starred, Number.parseInt(id), user.id);
            res.sendStatus(200);
        }
    };
}

const controller = Router();

controller

    // .use(requireSessionToken())
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
            res.status(405)
                .send('Online games cannot be added with this endpoint');
            return;
        }

        await addGame(game, req);

        res.sendStatus(200);

    })
    .post('/:id(\\d+)/star', createStarRoute(true))
    .post('/:id(\\d+)/unstar', createStarRoute(false))
    .get('/stars', async (req: Request, res: Response) => {
        const user = await getUserFromToken(req);
        if (!user) res.sendStatus(401);
        else {
            const idMaps = await useTypeOrm(Star)
                .createQueryBuilder()
                .select("gameId")
                .where("star.userId = :id", { id: user.id })
                .getRawMany();
            res.send({ gameIds: idMaps.map(e => e.gameId) });
        }
    });



export default controller;