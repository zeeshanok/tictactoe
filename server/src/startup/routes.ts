import { Express } from 'express';
import auth from '../controllers/auth.controller';
import users from '../controllers/user.controller';
import games from '../controllers/game.controller';


function setupRoutes(app: Express) {
    app.use('/auth', auth);
    app.use('/users', users);
    app.use('/games', games);
}

export default setupRoutes;