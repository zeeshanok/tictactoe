import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from "typeorm";
import ISession from "../model/session.model";
import { User } from "./user.entity";

@Entity()
export class Session implements ISession {

    @PrimaryGeneratedColumn()
    id!: number;

    @Column()
    refreshToken!: string;

    @Column()
    accessToken!: string;

    @Column()
    expiryTime!: number;

    @Column({ unique: true })
    sessionToken!: string;

    @Column()
    ip!: string;

    @OneToOne(() => User)
    @JoinColumn()
    user!: User;
}