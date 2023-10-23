import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from "typeorm";
import { User } from "./user.entity";

@Entity()
export class Session {

    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ nullable: true})
    refreshToken?: string;

    @Column()
    accessToken!: string;

    @Column({ unique: true })
    sessionToken!: string;

    @Column()
    ip!: string;

    @OneToOne(() => User, { onDelete: 'CASCADE' })
    @JoinColumn()
    user!: User;
}