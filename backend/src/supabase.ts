import { createClient, User } from '@supabase/supabase-js'


const supabaseAnon = createClient(
    'https://rwlnvnijfocuqumwkgmv.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3bG52bmlqZm9jdXF1bXdrZ212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk2MzE1NTMsImV4cCI6MjAxNTIwNzU1M30._D39c2b4uPFIMvPTwRADc9lQQLEBr9G-gx_pq8Zh1AY');

const supabaseAdmin = createClient(
    'https://rwlnvnijfocuqumwkgmv.supabase.co',
    '<YOUR SUPABASE ADMIN KEY>')

const addCoordinate = async ({ userId, latitude, longitude }: { userId: string, latitude: number, longitude: number }) => {
    const { data, error } = await supabaseAdmin
        .from('locations')
        .insert([
            { user_id: userId, location: `POINT(${latitude} ${longitude})` },
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

export { supabaseAnon, supabaseAdmin, addCoordinate, lookupUser };
