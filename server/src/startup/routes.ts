import { Express } from 'express';
import auth from '../controllers/auth.controller';
import users from '../controllers/user.controller';


function setupRoutes(app: Express) {
    app.use('/auth', auth);
    app.use('/users', users);
}

export default setupRoutes;