import { Entity, ManyToOne, PrimaryGeneratedColumn, Unique } from "typeorm";
import { User } from "./user.entity";
import { Game } from "./game.entity";

@Entity()
@Unique(["user", "game"])
export class Star {
    @PrimaryGeneratedColumn()
    id!: number;

    @ManyToOne(() => User, user => user.stars, { nullable: false })
    user!: User;

    @ManyToOne(() => Game, game => game.stars, { nullable: false })
    game!: Game;
}