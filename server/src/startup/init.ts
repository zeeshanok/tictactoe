import { Express } from 'express';

const port = 8090;

function setupApp(app: Express) {
    app.set('trust proxy', true);
    app.listen(port, '0.0.0.0', () => {
        console.log(`server started on port ${port}`);
    });
}

export default setupApp;