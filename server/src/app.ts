import express from 'express';
import setupApp from './startup/init';
import setupRoutes from './startup/routes';
import setupDatabase from './startup/database';
import cors from 'cors';
import morgan from 'morgan';

const app = express();

app.use(cors({ origin: true }));
app.use(morgan('dev'));
setupDatabase();
setupRoutes(app);
setupApp(app);