import express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import { waitForRun, openai, assistantId, doTranscription } from './openai';
import { User } from '@supabase/supabase-js'
import { createWalk, addCoordinate, lookupUser, saveBlobToStorage } from './supabase';
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

                const run = await openai.beta.threads.runs.create(threadId, {
                    assistant_id: assistantId,
                });

                waitForRun(threadId, run.id).then(async (message) => {
                    console.log("Message: ", message);
                    const transcription = await doTranscription(message);
                    console.log("Blobbing ", transcription);
                    const path = await saveBlobToStorage({ blob: transcription, fileName: `${run.id}.mp3` });
                    webSocket.send(JSON.stringify({ type: 'audio', path: path }));
                });
                // openai.beta.threads.messages.list(threadId).then((response) => {
                //     const messages = response.data;
                //     const lastMessage = messages[messages.length - 1];
                //     const content = lastMessage.content;
                //     console.log("Content: ", content);
                //     webSocket.send(JSON.stringify({ type: 'message', content: content }));
                // });

            } else if (json.type === 'location') {

                if (user === null) {
                    console.error('User is null');
                    return;
                }
                const location = json.location;
                await addCoordinate({
                    userId: user!.id,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    walk: threadId
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
