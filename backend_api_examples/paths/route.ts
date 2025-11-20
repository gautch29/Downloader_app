// app/api/paths/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { paths } from '@/db/schema';
import { getCurrentUser } from '@/lib/auth';

export async function GET(request: NextRequest) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { error: 'Unauthorized' },
                { status: 401 }
            );
        }

        const allPaths = await db.select().from(paths);

        return NextResponse.json({ paths: allPaths });
    } catch (error) {
        console.error('Get paths error:', error);
        return NextResponse.json(
            { error: 'Internal server error' },
            { status: 500 }
        );
    }
}

export async function POST(request: NextRequest) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { success: false, message: 'Unauthorized' },
                { status: 401 }
            );
        }

        const { name, path } = await request.json();

        if (!name || !path) {
            return NextResponse.json(
                { success: false, message: 'Name and path are required' },
                { status: 400 }
            );
        }

        const [newPath] = await db
            .insert(paths)
            .values({
                name,
                path,
                default: false,
            })
            .returning();

        return NextResponse.json({
            success: true,
            path: newPath,
        });
    } catch (error) {
        console.error('Add path error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
