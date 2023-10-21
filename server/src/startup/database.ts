import typeOrmConnect from "../database/typeorm";


export default async function setupDatabase() {
    await typeOrmConnect();
}