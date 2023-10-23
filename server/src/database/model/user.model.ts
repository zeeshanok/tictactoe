import IGame from "./game.model";

export default interface IUser {
    id: number;
    email: string;
    username?: string;
    bio?: string;
    profileUrl?: string;
    games: IGame[];
}