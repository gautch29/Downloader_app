#!/usr/bin/env tsx
/**
 * Database initialization script
 * Creates all necessary tables for the Downloader app
 */

import Database from 'better-sqlite3';
import { readFileSync } from 'fs';
import { join } from 'path';

const DB_PATH = process.env.DB_PATH || '/home/downloader-data/downloader.db';

console.log(`Initializing database at: ${DB_PATH}`);

try {
    // Open database connection
    const db = new Database(DB_PATH);

    // Read and execute schema
    const schemaPath = join(__dirname, 'schema.sql');
    const schema = readFileSync(schemaPath, 'utf-8');

    // Split by semicolon and execute each statement
    const statements = schema
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0);

    console.log(`Executing ${statements.length} SQL statements...`);

    for (const statement of statements) {
        db.exec(statement);
    }

    console.log('✅ Database schema created successfully!');

    // Verify tables were created
    const tables = db.prepare(`
    SELECT name FROM sqlite_master 
    WHERE type='table' 
    ORDER BY name
  `).all();

    console.log('\nCreated tables:');
    tables.forEach((table: any) => {
        console.log(`  - ${table.name}`);
    });

    db.close();

} catch (error) {
    console.error('❌ Error initializing database:', error);
    process.exit(1);
}
