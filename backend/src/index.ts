import express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import { openai } from './openai';
import { User } from '@supabase/supabase-js'
import { runThreadAndGetTranscript } from './interactions';
import { createWalk, addCoordinate, lookupUser, getRecentCoordinates, getLastCoordinate, getFirstCoordinate, getLastDistance, writeDistance } from './supabase';
import { calculateBearing, distance } from './bearings';
const app = express();

const server = http.createServer(app);
const webSocketServer = new WebSocket.Server({ server });

const VOICES: Array<'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer'> = ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];

const webSocketHandler = (webSocket: WebSocket) => {
    let user: User | null = null;
    let threadId: string | null = null;
    let voice: 'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer' | null;
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
                user = await lookupUser({ token: token });

                const explorerName = json.explorerName || user!.user_metadata.full_name;

                const thread = await openai.beta.threads.create({
                    messages: [{
                        content: `I am ${explorerName}. Please tell me a story.`,
                        role: 'user',
                    }]
                });
                threadId = thread.id;
                voice = VOICES[Math.floor(Math.random() * VOICES.length)];
                await createWalk({ userId: user!.id, threadId: threadId });

                const path = await runThreadAndGetTranscript(threadId, voice);
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
                    console.log(threadId);
                    console.log(locations);
                    const choices = ['left', 'right', 'forward'];
                    let direction;
                    try {
                        const recentLocation = locations[locations.length - 1];
                        const middleLocation = locations[Math.floor(locations.length * 2 / 3)];
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
                        console.log("Initial bearing", initialBearing);
                        console.log("Final bearing", finalBearing);
                        console.log("Bearing change", finalBearing - initialBearing);


                        const bearingChange = finalBearing - initialBearing;
                        if (bearingChange > 45 && bearingChange <= 135) {
                            direction = 'right';
                        } else if (bearingChange < -45 && bearingChange >= -135) {
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

                    const path = await runThreadAndGetTranscript(threadId, voice!);
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
            } else if (json.type === 'distance') {
                if (user === null || threadId === null) {
                    console.error('User or threadId is null');
                    return;
                }

                try {
                    const firstLocation = await getFirstCoordinate(threadId);
                    if (firstLocation === null) {
                        console.error('First location is null');
                        return;
                    }
                    const lastLocation = await getLastCoordinate(threadId);
                    if (firstLocation.longitude == lastLocation.longitude &&
                        firstLocation.latitude == lastLocation.latitude) {
                        return;
                    }
                    let recentDistance = await getLastDistance(threadId);

                    if (recentDistance === null) {
                        recentDistance = {
                            latitude: firstLocation.latitude,
                            longitude: firstLocation.longitude,
                            distance: 0
                        };
                    }
                    const addedDistance = distance(
                        recentDistance.latitude,
                        recentDistance.longitude,
                        lastLocation.latitude,
                        lastLocation.longitude);

                    await writeDistance(
                        threadId,
                        user.id,
                        lastLocation.latitude,
                        lastLocation.longitude,
                        addedDistance + recentDistance.distance);

                    webSocket.send(JSON.stringify({ type: 'distance', distance: addedDistance + recentDistance.distance }));
                } catch (e) {
                    console.error(e);
                }
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
