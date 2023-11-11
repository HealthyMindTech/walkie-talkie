import express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import { openai } from './openai';
import { User } from '@supabase/supabase-js'
import { runThreadAndGetTranscript } from './interactions';
import { createWalk, addCoordinate, lookupUser, getRecentCoordinates } from './supabase';
import { calculateBearing } from './bearings';
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
                setTimeout(async () => {
                    if (threadId === null) {
                        return;
                    }
                    const locations = await getRecentCoordinates(threadId);
                    const choices = ['left', 'right', 'forward'];
                    let direction;
                    try {
                        const recentLocation = locations[locations.length - 1];
                        const middleLocation = locations[Math.floor(locations.length * 3 / 2)];
                        const firstLocation = locations[0];
                        const initialBearing = calculateBearing(
                            firstLocation.latitude,
                            firstLocation.longitude,
                            middleLocation.latitude,
                            middleLocation.longitude);
                        const finalBearing = calculateBearing(
                            middleLocation.latitude,
                            middleLocation.longitude,
                            recentLocation.latitude,
                            recentLocation.longitude);
                        const bearingChange = finalBearing - initialBearing;
                        if (bearingChange > 45 && bearingChange <= 135) {
                            direction = 'right';
                        } else if (bearingChange <= -45 && bearingChange >= -135) {
                            direction = 'left';
                        } else {
                            direction = 'forward';
                        }
                    } catch (e) {
                        console.error(e);
                        direction = choices[Math.floor(Math.random() * choices.length)];
                    }

                    console.log(`Direction is: ${direction}`);

                    await openai.beta.threads.messages.create(threadId, {
                        content: `I walked ${direction}.`,
                        role: 'user',
                    });

                    const path = await runThreadAndGetTranscript(threadId);
                    webSocket.send(JSON.stringify({ type: 'audio', path: path }));
                }, 5000);
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
