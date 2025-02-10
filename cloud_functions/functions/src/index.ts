import {onCall} from "firebase-functions/v2/https";
import { defineString } from 'firebase-functions/params';
import { SessionsClient } from "@google-cloud/dialogflow-cx";

exports.detectIntent = onCall({region: "asia-northeast1"}, async (request) => {
    const projectId = defineString('PROJECT_ID').value();
    const location = defineString('REGION').value();
    const agentId = defineString('AGENT_APP_ID').value();
    const sessionId = request.data["sessionId"] || 'test-session';

    console.log('projectId:', projectId);
    
    const client = new SessionsClient({
        apiEndpoint: `${location}-dialogflow.googleapis.com`
    });
    const sessionPath = client.projectLocationAgentSessionPath(
        projectId,
        location,
        agentId,
        sessionId
    );
    

    const requestBody = {
        session: sessionPath,
        queryInput: {
            text: {
                text: request.data["text"] || 'こんにちは',
            },
            languageCode: 'ja',
        },
    };

    try {
        const [response] = await client.detectIntent(requestBody);
        const result = response.queryResult?.responseMessages
            ?.map(m => m.text?.text || [])
            .flat();

        return { result };
    } catch (error) {
        console.error('Dialogflow Error:', error);
        return { error: error };
    }
});