// app/api/downloads/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { downloads } from '@/db/schema';
import { desc } from 'drizzle-orm';
import { getCurrentUser } from '@/lib/auth'; // You'll need to implement this helper

export async function GET(request: NextRequest) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { error: 'Unauthorized' },
                { status: 401 }
            );
        }

        const allDownloads = await db
            .select()
            .from(downloads)
            .orderBy(desc(downloads.added_at));

        return NextResponse.json({ downloads: allDownloads });
    } catch (error) {
        console.error('Get downloads error:', error);
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

        const { url, path_id } = await request.json();

        if (!url) {
            return NextResponse.json(
                { success: false, message: 'URL is required' },
                { status: 400 }
            );
        }

        // Validate 1fichier URL
        if (!url.includes('1fichier.com')) {
            return NextResponse.json(
                { success: false, message: 'Invalid 1fichier URL' },
                { status: 400 }
            );
        }

        const [download] = await db
            .insert(downloads)
            .values({
                url,
                status: 'pending',
                path_id: path_id || null,
                added_at: new Date(),
            })
            .returning();

        return NextResponse.json({
            success: true,
            download,
        });
    } catch (error) {
        console.error('Add download error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
