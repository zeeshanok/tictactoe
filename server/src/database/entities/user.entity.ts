import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Star } from './star.entity';

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

    @OneToMany(() => Star, star => star.user)
    stars!: Star[];
}