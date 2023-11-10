import express from 'express';
import * as http from 'http';
import * as WebSocket from 'ws';
import OpenAI from 'openai';
import { User } from '@supabase/supabase-js'
import { addCoordinate, lookupUser } from './supabase';
const app = express();

const server = http.createServer(app);
const webSocketServer = new WebSocket.Server({ server });

const openai = new OpenAI({ apiKey: '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' });

const webSocketHandler = (webSocket: WebSocket) => {
    let user: User | null = null;
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
                console.log(`User: ${user}`);
                webSocket.send(JSON.stringify({
                    type: 'message',
                    data: {
                        text: `Hello ${user?.email}`
                    }
                }));
            } else if (json.type === 'location') {

                if (user === null) {
                    console.error('User is null');
                    return;
                }
                const location = json.location;
                await addCoordinate({ userId: user!.id, latitude: location.latitude, longitude: location.longitude });
                console.log(`Added location: ${location.latitude}, ${location.longitude}`);
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
