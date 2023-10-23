import IUser from "./user.model";

export default interface ISession {
    id: number;
    sessionToken: string;
    ip: string;
    refreshToken?: string;
    accessToken: string;
    user: IUser;
}