import { Column, CreateDateColumn, Entity, OneToMany, PrimaryGeneratedColumn } from "typeorm";
import { Star } from "./star.entity";

export type GameType = 'computer' | 'local-multiplayer' | 'online';

@Entity()
export class Game {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column()
    moves!: string;

    @Column()
    type!: GameType;

    @CreateDateColumn()
    createdAt!: Date;

    /**
     * The time this game took to finish (in seconds)
     */
    @Column()
    timePlayed!: number;

    /**
     * If numerical then it corresponds to a user id, if it is a string it corresponds to
     * either an offline player's name or a computer player.
     */
    @Column("text", { nullable: true })
    playerX!: string | null;

    /**
     * If numerical then it corresponds to a user id, if it is a string it corresponds to
     * an offline player's name, and if null it corresponds to a computer player.
     */
    @Column("text", { nullable: true })
    playerO!: string | null;

    @OneToMany(() => Star, star => star.game)
    stars!: Star[];
}