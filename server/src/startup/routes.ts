import { Express } from 'express';
import auth from '../controllers/auth.controller';
import users from '../controllers/user.controller';
import games from '../controllers/game.controller';
import multiplayer from '../controllers/multiplayer.controller';


function setupRoutes(app: Express) {
    app.use('/auth', auth);
    app.use('/users', users);
    app.use('/games', games);
    app.use('/multiplayer', multiplayer);
}

export default setupRoutes;