// app/api/auth/session/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { db } from '@/db';
import { sessions, users } from '@/db/schema';
import { eq, and, gt } from 'drizzle-orm';

export async function GET(request: NextRequest) {
    try {
        const sessionId = cookies().get('session_id')?.value;

        if (!sessionId) {
            return NextResponse.json({ authenticated: false, user: null });
        }

        // Find session and user
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
            cookies().delete('session_id');
            return NextResponse.json({ authenticated: false, user: null });
        }

        return NextResponse.json({
            authenticated: true,
            user: {
                id: sessionData.user.id,
                username: sessionData.user.username,
            },
        });
    } catch (error) {
        console.error('Session check error:', error);
        return NextResponse.json({ authenticated: false, user: null });
    }
}
