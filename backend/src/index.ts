import express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import { openai } from './openai';
import { User } from '@supabase/supabase-js'
import { runThreadAndGetTranscript } from './interactions';
import { createWalk, addCoordinate, lookupUser, getRecentCoordinates } from './supabase';
const app = express();

const server = http.createServer(app);
const webSocketServer = new WebSocket.Server({ server });

const webSocketHandler = (webSocket: WebSocket) => {
    let user: User | null = null;
    let threadId: string | null = null;

    webSocket.on('message', async (message: string) => {
        let json: any;
        try {
            json = JSON.parse(message);
        } catch (e) {
            console.error(e);
            return;
        }

        try {
            if (json.type === 'login') {
                const token = json.token;
                const storyStart = json.storyStart;
                user = await lookupUser({ token: token });

                console.log("Creating thread");
                const thread = await openai.beta.threads.create({
                    messages: [{
                        content: storyStart || "start",
                        role: 'user',
                    }]
                });
                threadId = thread.id;
                await createWalk({ userId: user!.id, threadId: threadId });

                const path = await runThreadAndGetTranscript(threadId);
                webSocket.send(JSON.stringify({ type: 'audio', path: path }));

            } else if (json.type === 'generate_new_chunk') {
                if (threadId === null) {
                    return;
                }
                const locations = await getRecentCoordinates(threadId);
                if (locations.length < 3) {
                }

                await openai.beta.threads.messages.create(threadId, {
                    content: 'I walked to the left.',
                    role: 'user',
                });

                const path = await runThreadAndGetTranscript(threadId);
                webSocket.send(JSON.stringify({ type: 'audio', path: path }));


            } else if (json.type === 'location') {

                if (user === null || threadId === null) {
                    console.error('User or threadId is null');
                    return;
                }
                const location = json.location;
                await addCoordinate({
                    userId: user.id,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    walkId: threadId
                });
            } else {
                console.error(`Unknown message type: ${json.type}`);
            }
        } catch (e) {
            console.error(e);
        }
    });
};

webSocketServer.on('connection', webSocketHandler);



server.listen(process.env.PORT || 8080, () => {
    console.log('Server started');
});
