#!/usr/bin/env tsx
/**
 * Create a new user
 * Usage: npm run create-user
 */

import Database from 'better-sqlite3';
import bcrypt from 'bcrypt';
import { createInterface } from 'readline';

const DB_PATH = process.env.DB_PATH || '/home/downloader-data/downloader.db';

const rl = createInterface({
    input: process.stdin,
    output: process.stdout
});

function question(query: string): Promise<string> {
    return new Promise(resolve => rl.question(query, resolve));
}

async function createUser() {
    console.log('Create a new user\n');

    const username = await question('Username: ');
    const password = await question('Password: ');

    if (!username || !password) {
        console.error('❌ Username and password are required');
        process.exit(1);
    }

    try {
        const db = new Database(DB_PATH);

        // Check if user already exists
        const existing = db.prepare('SELECT id FROM users WHERE username = ?').get(username);
        if (existing) {
            console.error(`❌ User '${username}' already exists`);
            db.close();
            process.exit(1);
        }

        // Hash password
        const passwordHash = await bcrypt.hash(password, 10);

        // Insert user
        const result = db.prepare(`
      INSERT INTO users (username, password_hash)
      VALUES (?, ?)
    `).run(username, passwordHash);

        console.log(`✅ User '${username}' created successfully! (ID: ${result.lastInsertRowid})`);

        db.close();

    } catch (error) {
        console.error('❌ Error creating user:', error);
        process.exit(1);
    } finally {
        rl.close();
    }
}

createUser();
