// app/api/downloads/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { downloads } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { getCurrentUser } from '@/lib/auth';

export async function GET(
    request: NextRequest,
    { params }: { params: { id: string } }
) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { error: 'Unauthorized' },
                { status: 401 }
            );
        }

        const id = parseInt(params.id);
        const [download] = await db
            .select()
            .from(downloads)
            .where(eq(downloads.id, id))
            .limit(1);

        if (!download) {
            return NextResponse.json(
                { error: 'Download not found' },
                { status: 404 }
            );
        }

        return NextResponse.json(download);
    } catch (error) {
        console.error('Get download error:', error);
        return NextResponse.json(
            { error: 'Internal server error' },
            { status: 500 }
        );
    }
}

export async function DELETE(
    request: NextRequest,
    { params }: { params: { id: string } }
) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { success: false, message: 'Unauthorized' },
                { status: 401 }
            );
        }

        const id = parseInt(params.id);

        // Update status to cancelled
        await db
            .update(downloads)
            .set({ status: 'cancelled' })
            .where(eq(downloads.id, id));

        return NextResponse.json({
            success: true,
            message: 'Download cancelled',
        });
    } catch (error) {
        console.error('Cancel download error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
