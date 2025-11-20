// app/api/paths/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { paths } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { getCurrentUser } from '@/lib/auth';

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

        // Check if it's the default path
        const [path] = await db
            .select()
            .from(paths)
            .where(eq(paths.id, id))
            .limit(1);

        if (path?.default) {
            return NextResponse.json(
                { success: false, message: 'Cannot delete default path' },
                { status: 400 }
            );
        }

        await db.delete(paths).where(eq(paths.id, id));

        return NextResponse.json({
            success: true,
            message: 'Path deleted',
        });
    } catch (error) {
        console.error('Delete path error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
