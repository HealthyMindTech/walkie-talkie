import { createClient, User } from '@supabase/supabase-js'


const supabaseAnon = createClient(
    'https://rwlnvnijfocuqumwkgmv.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3bG52bmlqZm9jdXF1bXdrZ212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk2MzE1NTMsImV4cCI6MjAxNTIwNzU1M30._D39c2b4uPFIMvPTwRADc9lQQLEBr9G-gx_pq8Zh1AY');

const supabaseAdmin = createClient(
    'https://rwlnvnijfocuqumwkgmv.supabase.co',
    '<YOUR SUPABASE ADMIN KEY>')

const addCoordinate = async ({ userId, latitude, longitude, walkId }: { walkId: string, userId: string, latitude: number, longitude: number }) => {
    const { data, error } = await supabaseAdmin
        .from('locations')
        .insert([
            { walk_id: walkId, user_id: userId, latitude: latitude, longitude: longitude },
        ]);
    if (error) {
        console.log(`Error: ${error.message}`, error, data);
        console.error(error.message);
        throw new Error(error.message);
    }
}

const createWalk = async ({ userId, threadId }: { userId: string, threadId: string }): Promise<void> => {
    const { data, error } = await supabaseAdmin
        .from('walks')
        .insert([
            { user_id: userId, id: threadId },
        ]);
    if (error) {
        console.log(`Error: ${error.message}`, error, data);
        console.error(error.message);
        throw new Error(error.message);
    }
}

const lookupUser = async ({ token }: { token: string }): Promise<User> => {
    const { data, error } = await supabaseAdmin.auth.getUser(token);
    if (error) {
        console.error(error);
        throw new Error(error.message);
    }
    return data.user;
}

const saveBlobToStorage = async ({ blob, fileName }: { blob: ArrayBuffer, fileName: string }) => {
    const { data, error } = await supabaseAdmin.storage
        .from('audio')
        .upload(fileName, blob, {
            contentType: 'audio/mpeg'
        });


    if (error) {
        console.error(error, error.message);
        throw new Error(error.message);
    }
    return data.path;
}

const getRecentCoordinates = async (walkId: string): Promise<Array<{
    latitude: number, longitude: number, timestamp: string
}>> => {
    const { data, error } = await supabaseAdmin
        .from('locations')
        .select('longitude, latitude, created_at')
        .eq('walk_id', walkId)
        .order('created_at', { ascending: false })
        .limit(20);

    if (error) {
        console.error(error, error.message);
        throw new Error(error.message);
    }

    return data.map((d: any) => {
        return {
            timestamp: d.created_at,
            latitude: d.latitude,
            longitude: d.longitude
        }
    });
}

export {
    supabaseAnon,
    supabaseAdmin,
    addCoordinate,
    lookupUser,
    createWalk,
    saveBlobToStorage,
    getRecentCoordinates
};
