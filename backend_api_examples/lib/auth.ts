// lib/auth.ts
import { NextRequest } from 'next/server';
import { cookies } from 'next/headers';
import { db } from '@/db';
import { sessions, users } from '@/db/schema';
import { eq, and, gt } from 'drizzle-orm';

export async function getCurrentUser(request: NextRequest) {
    try {
        const sessionId = cookies().get('session_id')?.value;

        if (!sessionId) {
            return null;
        }

        const [sessionData] = await db
            .select({
                session: sessions,
                user: users,
            })
            .from(sessions)
            .innerJoin(users, eq(sessions.user_id, users.id))
            .where(
                and(
                    eq(sessions.id, sessionId),
                    gt(sessions.expires_at, new Date())
                )
            )
            .limit(1);

        if (!sessionData) {
            return null;
        }

        return {
            id: sessionData.user.id,
            username: sessionData.user.username,
        };
    } catch (error) {
        console.error('Get current user error:', error);
        return null;
    }
}
