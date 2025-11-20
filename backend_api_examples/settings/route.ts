// app/api/settings/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { settings } from '@/db/schema';
import { eq } from 'drizzle-orm';
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

        const allSettings = await db.select().from(settings);

        // Convert array to object
        const settingsObj: any = {
            '1fichier_api_key': null,
            plex_url: null,
            plex_token: null,
        };

        allSettings.forEach((setting) => {
            settingsObj[setting.key] = setting.value;
        });

        return NextResponse.json({ settings: settingsObj });
    } catch (error) {
        console.error('Get settings error:', error);
        return NextResponse.json(
            { error: 'Internal server error' },
            { status: 500 }
        );
    }
}

export async function PUT(request: NextRequest) {
    try {
        const user = await getCurrentUser(request);
        if (!user) {
            return NextResponse.json(
                { success: false, message: 'Unauthorized' },
                { status: 401 }
            );
        }

        const body = await request.json();
        const settingsToUpdate = [
            { key: '1fichier_api_key', value: body['1fichier_api_key'] },
            { key: 'plex_url', value: body.plex_url },
            { key: 'plex_token', value: body.plex_token },
        ];

        for (const setting of settingsToUpdate) {
            if (setting.value !== undefined && setting.value !== null) {
                // Check if setting exists
                const [existing] = await db
                    .select()
                    .from(settings)
                    .where(eq(settings.key, setting.key))
                    .limit(1);

                if (existing) {
                    await db
                        .update(settings)
                        .set({ value: setting.value })
                        .where(eq(settings.key, setting.key));
                } else {
                    await db.insert(settings).values({
                        key: setting.key,
                        value: setting.value,
                    });
                }
            }
        }

        return NextResponse.json({
            success: true,
            message: 'Settings updated',
        });
    } catch (error) {
        console.error('Update settings error:', error);
        return NextResponse.json(
            { success: false, message: 'Internal server error' },
            { status: 500 }
        );
    }
}
