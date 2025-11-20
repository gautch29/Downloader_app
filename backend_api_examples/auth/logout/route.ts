// app/api/auth/logout/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { db } from '@/db';
import { sessions } from '@/db/schema';
import { eq } from 'drizzle-orm';

export async function POST(request: NextRequest) {
    try {
        const sessionId = cookies().get('session_id')?.value;

        if (sessionId) {
            // Delete session from database
            await db.delete(sessions).where(eq(sessions.id, sessionId));

            // Clear cookie
            cookies().delete('session_id');
        }

        return NextResponse.json({ success: true });
    } catch (error) {
        console.error('Logout error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
