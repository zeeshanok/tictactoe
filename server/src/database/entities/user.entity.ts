import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import IUser from '../model/user.model';

@Entity()
export class User implements IUser {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({unique: true})
    email!: string;

    @Column({nullable: true, unique: true})
    username!: string;

    @Column({nullable: true})
    bio!: string;

    @Column({nullable: true})
    profileUrl!: string;

    
}