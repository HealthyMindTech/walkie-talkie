import OpenAI from 'openai';
import { ThreadMessagesPage } from 'openai/resources/beta/threads/messages';

const assistantId = 'asst_EMkAqBVDL1f0ZbHRaLCAzPE7';

const openai = new OpenAI({ apiKey: '<YOUR OPENAI API KEY>' });



const waitForRun = async (threadId: string, runId: string): Promise<string> => {
    const run = await openai.beta.threads.runs.retrieve(threadId, runId);
    console.log(run);
    if (run.status === 'completed') {
        const messages = await openai.beta.threads.messages.list(threadId);

        console.log(messages);
        return messages.data[0].content.map((m) => m.type === 'text' ? m.text.value : '').join('\n');
    } else if (run.status === 'in_progress' || run.status === 'queued') {
        return new Promise((resolve) => {
            setTimeout(async () => {
                const result = await waitForRun(threadId, runId);
                resolve(result);
            }, 1000);
        });
    }
    throw new Error(`Run failed with status: ${run.status}`);
}


const doTranscription = async (text: string): Promise<ArrayBuffer> => {
    const resp = await openai.audio.speech.create({
        model: "tts-1",
        voice: "shimmer",
        input: text,
    });

    return await resp.arrayBuffer();
}
export { openai, assistantId, waitForRun, doTranscription }
