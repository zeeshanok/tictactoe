import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity()
export class User {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ unique: true })
    email!: string;

    @Column({ nullable: true, unique: true })
    username!: string;

    @Column({ nullable: true })
    bio!: string;

    @Column({ nullable: true })
    profileUrl!: string;

}