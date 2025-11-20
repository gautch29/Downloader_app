// app/api/paths/[id]/default/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { paths } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { getCurrentUser } from '@/lib/auth';

export async function PUT(
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

        // Set all paths to non-default
        await db.update(paths).set({ default: false });

        // Set the specified path as default
        await db
            .update(paths)
            .set({ default: true })
            .where(eq(paths.id, id));

        return NextResponse.json({
            success: true,
            message: 'Path set as default',
        });
    } catch (error) {
        console.error('Set default path error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
