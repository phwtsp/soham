const express = require('express');
const admin = require('firebase-admin');
const bodyParser = require('body-parser');
const serviceAccount = require('./serviceAccountKey.json');

// Inicializa o Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const app = express();

// Middleware para fazer o parse do JSON
app.use(bodyParser.json());

const PORT = process.env.PORT || 3000;

// Rota de verificação de saúde do servidor
app.get('/', (req, res) => {
    res.send('Servidor rodando corretamente.');
});

// Endpoint do Webhook RevenueCat
app.post('/webhooks/revenuecat', async (req, res) => {
    try {
        const event = req.body.event;

        if (!event) {
            console.error('Evento não encontrado no corpo da requisição');
            return res.status(400).send('Corpo da requisição inválido');
        }

        const type = event.type;
        const userId = event.app_user_id; // auth_uid no Firebase

        console.log(`Recebido evento: ${type} para o usuário: ${userId}`);

        if (!userId) {
            console.error('User ID indefinido no evento');
            return res.status(400).send('User ID ausente');
        }

        const userRef = db.collection('users').doc(userId);

        if (type === 'INITIAL_PURCHASE' || type === 'RENEWAL') {
            // Usuário comprou ou renovou: set is_premium = true
            await userRef.set({ is_premium: true }, { merge: true });
            console.log(`Usuário ${userId} atualizado para PREMIUM.`);
        } else if (type === 'EXPIRATION') {
            // Assinatura expirou: set is_premium = false
            await userRef.set({ is_premium: false }, { merge: true });
            console.log(`Usuário ${userId} atualizado para FREE (Expirado).`);
        } else {
            console.log(`Evento ${type} ignorado.`);
        }

        res.status(200).send('Webhook recebido com sucesso');

    } catch (error) {
        console.error('Erro ao processar webhook:', error);
        res.status(500).send('Erro interno do servidor');
    }
});

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
