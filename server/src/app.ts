import express from 'express';
import setupApp from './startup/init';
import setupRoutes from './startup/routes';
import setupDatabase from './startup/database';

const app = express();

setupDatabase();
setupRoutes(app);
setupApp(app);