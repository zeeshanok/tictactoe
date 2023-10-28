import { Request, Response, Router } from "express";
import { requireSessionToken } from "./common";
import { randomInt } from "crypto";
import { RawData, WebSocket, WebSocketServer } from "ws";
import { Game } from "../database/entities/game.entity";
import { useTypeOrm } from "../database/typeorm";

const controller = Router();

const wss = new WebSocketServer({ port: 8091 });

type UserIdWebSocketPair = { userId: number; ws: WebSocket; };
type GameClients = { [gameCode: number]: { x?: UserIdWebSocketPair; o?: UserIdWebSocketPair; }; };

const gameClients: GameClients = {};

const readyIds = new Set<number>([112233]);

function generateGameCode() {
    let id;
    do { id = randomInt(100_000, 1_000_000); }
    while (gameClients[id] != undefined || readyIds.has(id));
    return id;
}

async function createGame(game: Partial<Game>) {
    await useTypeOrm(Game).save({ ...game, type: 'online' });
}

function handleGame(code: number) {
    const game = gameClients[code]!;
    const players = [game.x!, game.o!];

    const initialTime: Date = new Date();

    const closeConnections = () => players.forEach((p) => p.ws.close());

    const endGameGracefully = (moves: string) => {
        const timePlayed = (new Date()).getSeconds() - initialTime.getSeconds();
        createGame({
            moves,
            timePlayed,
            playerX: players[0].userId.toString(),
            playerO: players[1].userId.toString(),
        });
    };


    const onPlayerMessage = (index: 0 | 1) => players[index].ws.on('message', (data: RawData) => {
        const msg = data.toString().toLowerCase();
        if (msg.startsWith('end')) {
            const moves = msg.substring('end'.length);
            endGameGracefully(moves);
            closeConnections();
        }
        players[1 - index].ws.send(msg);
    });
    const onPlayerDisconnect = (index: 0 | 1) => players[index].ws.on('close', () => {
        players[1 - index].ws.send('disconnect');
        closeConnections();
    });

    onPlayerMessage(0);
    onPlayerMessage(1);
    onPlayerDisconnect(0);
    onPlayerDisconnect(1);
    players[0].ws.send('play');
}

wss.on('connection', (ws: WebSocket) => {
    ws.once('message', (data: RawData) => {

        // {game code}{player type?}{user id}
        // example 112233o3 (game code: 112233, player type: o, user id: 3)
        // a player type isn't expected when a user is joining an existing game 
        // occupied by one other user.
        const parts = data.toString().toLowerCase().match(/^(\d{6})([xo]?)(\d+)$/)?.slice(1);

        if (parts !== undefined && parts[2] !== undefined) {

            const code = Number.parseInt(parts[0]);
            const userId = Number.parseInt(parts[2]);
            const pair: UserIdWebSocketPair = { userId, ws };

            if (readyIds.has(code)) {
                // starting the wait for an opponent player
                readyIds.delete(code);
                gameClients[code] = {};
                gameClients[code][parts[1] as 'x' | 'o'] = pair;
                return;

            } else if (gameClients[code] !== undefined) {
                // we are the opponent player
                const message = `youare${userId}`;
                if (!gameClients[code].x) {
                    gameClients[code].x = pair;
                    const o = gameClients[code].o!;
                    o.ws.send(`${message}o`);
                    pair.ws.send(`youare${o.userId}x`);
                } else {
                    gameClients[code].o = pair;
                    const x = gameClients[code].x!;
                    x.ws.send(`${message}x`);
                    pair.ws.send(`youare${x.userId}o`);
                }
                handleGame(code);
                return;
            }
        }
        // if it reaches here the game doesn't exist
        console.log("requested game doesn't exist, disconnecting...");
        ws.send('DNE'); // does not exist
        ws.close();
    });
});

controller

    .use(requireSessionToken())
    .post('/', (_req: Request, res: Response) => {
        const gameCode = generateGameCode();
        readyIds.add(gameCode);
        res.send({ gameCode });
    });


export default controller;