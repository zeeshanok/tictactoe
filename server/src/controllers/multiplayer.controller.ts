import { Request, Response, Router } from "express";
import { requireSessionToken } from "./common";
import { randomInt } from "crypto";
import { RawData, WebSocket, WebSocketServer } from "ws";

const controller = Router();

const wss = new WebSocketServer({ port: 8091 });

type UserIdWebSocketPair = { userId: number; ws: WebSocket; };
type GameClients = { [gameCode: number]: { x?: UserIdWebSocketPair; o?: UserIdWebSocketPair; }; };

const gameClients: GameClients = {};

const readyIds = new Set<number>([112233]);

function generateGameCode() {
    let id;
    do { id = randomInt(100_000, 1_000_000); }
    while (gameClients[id] != undefined);
    return id;
}

function handleGame(code: number) {
    const game = gameClients[code]!;
    const players = [game.x!, game.o!];

    const closeConnections = () => players.forEach((p) => p.ws.close());
    const endGame = () => { };

    const onPlayerMessage = (num: 0 | 1) => players[num].ws.on('message', (data: RawData) => {
        const msg = data.toString();
        if (msg === 'end') {
            endGame();
            closeConnections();
        }
        players[1 - num].ws.send(msg);
    });

    onPlayerMessage(0);
    onPlayerMessage(1);
    players[0].ws.send('play');
}

wss.on('connection', (ws: WebSocket) => {
    console.log('incoming connection');
    ws.once('message', (data: RawData) => {
        console.log(`incoming message ${data.toString()}`);

        // {game code}{player type?}{user id}
        // example 112233o3 (game code: 112233, player type: o, user id: 3)
        const parts = data.toString().match(/^(\d{6})([xo]?)(\d+)$/)?.slice(1);
        if (parts !== undefined && parts[2] !== undefined) {
            const code = Number.parseInt(parts[0]);
            const userId = Number.parseInt(parts[2]);
            const idPair: UserIdWebSocketPair = { userId, ws };
            if (readyIds.has(code)) {
                // starting the wait for an opponent player
                readyIds.delete(code);
                gameClients[code] = {};
                gameClients[code][parts[1] as 'x' | 'o'] = idPair;
                console.log('created new game');
                return;
            } else if (gameClients[code] !== undefined) {
                // we are the opponent player
                const message = `joined${userId}`;
                if (!gameClients[code].x) {
                    gameClients[code].x = idPair;
                    const o = gameClients[code].o!;
                    o.ws.send(message);
                    idPair.ws.send(`joined${o.userId}`);
                } else {
                    gameClients[code].o = idPair;
                    const x = gameClients[code].x!;
                    x.ws.send(message);
                    idPair.ws.send(`joined${x.userId}`);
                }
                handleGame(code);
                return;
            }
        }
        // if it reaches here the game doesn't exist
        console.log("requested game does'nt existsSync, disconnecting...");
        ws.close();
    });
});

controller

    .use(requireSessionToken())
    .post('/', (req: Request, res: Response) => {
        const gameCode = generateGameCode();
        readyIds.add(gameCode);
        res.send({ gameCode });
    });


export default controller;