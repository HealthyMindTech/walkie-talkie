import { waitForRun, openai, assistantId, doTranscription } from './openai';
import { saveBlobToStorage } from './supabase';

const runThreadAndGetTranscript = async (threadId: string): Promise<string> => {
    const run = await openai.beta.threads.runs.create(threadId, {
        assistant_id: assistantId,
    });

    const message = await waitForRun(threadId, run.id);
    console.log("Message: ", message);
    const transcription = await doTranscription(message);
    console.log("Blobbing ", transcription);
    const path = await saveBlobToStorage({ blob: transcription, fileName: `${run.id}.mp3` });

    return path;
}

export { runThreadAndGetTranscript };
