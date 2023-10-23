import { DataSource, EntityTarget, ObjectLiteral, Repository } from 'typeorm';

let ormDb: DataSource;

export default async function typeOrmConnect(): Promise<void> {
    const source = new DataSource({
        type: 'sqlite',
        database: 'db.sqlite',
        entities: [`${__dirname}/entities/*.entity.[jt]s`, ],
        synchronize: true,
    });
    ormDb = await source.initialize();
}

export function useTypeOrm<T extends ObjectLiteral>(entity: EntityTarget<T>): Repository<T> {
    return ormDb.getRepository<T>(entity);
}