const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}

const db = admin.firestore();

async function migrateUsers() {
    console.log('Starting migration...');
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();

    if (snapshot.empty) {
        console.log('No matching documents.');
        return;
    }

    const batch = db.batch();
    let count = 0;

    snapshot.docs.forEach(doc => {
        const data = doc.data();
        if (data.is_premium === undefined) {
            console.log(`Updating user ${doc.id} to non-premium`);
            batch.update(doc.ref, { is_premium: false });
            count++;
        }
    });

    if (count > 0) {
        await batch.commit();
        console.log(`Updated ${count} users.`);
    } else {
        console.log('All users already have is_premium field.');
    }
}

migrateUsers().then(() => process.exit(0)).catch(console.error);
