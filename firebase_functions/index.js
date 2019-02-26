const functions = require('firebase-functions');
const admin = require('firebase-admin');
const natural = require('natural');
admin.initializeApp();

exports.user_login_firestore = functions.auth.user().onCreate((user, context) => {
    const uid = user.uid;
    let name = user.displayName;
    if (name === "" || name === null) {
        if (user.email) {
            name = user.email;
        } else if (user.phoneNumber) {
            name = user.phoneNumber;
        } else {
            name = uid;
        }
    }

    const firestore = admin.firestore();
    const doc = firestore.doc('users/' + uid);
    return doc.set({
        name: name
    }).catch((error) => {
        console.error('FUNCTIONS - user_login_firestore ERROR (writing to firestore):');
        console.error(error)
    });
});

exports.pack_uploaded = functions.firestore.document('packs/{packID}').onWrite((change, context) => {
    if (!change.after.exists) { return 0 }
    const doc = change.after;
    const name = doc.get('name');
    
    const wordTokens = new natural.WordTokenizer().tokenize(name);
    const wordTokensLowercased = wordTokens.map((str) => { return str.toLowerCase() });
    
    return doc.ref.update({
        search_terms: wordTokensLowercased
    });
});

exports.count_downloads = functions.https.onCall((data, context) => {
    if (data === null || typeof data.packID !== 'string') {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with one argument "packID" and it must be a string.');
    }
    const packID = data.packID;
    if (packID.includes('/')) {
        throw new functions.https.HttpsError('invalid-argument', 'The value of "packID" is invalid.');
    }

    const db = admin.firestore();
    return db.runTransaction((transaction) => {
        let docRef = db.doc('packs/' + packID);
        return transaction.get(docRef).then(doc => {
            if (!doc.exists) { return Promise.reject(new functions.https.HttpsError('invalid-argument', '"packID" does not exist.')) }
            let downloads = doc.get('downloads');
            if (typeof downloads !== 'number') { // downloads cannot be `null` because `typeof null === 'object'`
                downloads = 0;
            }
            downloads++;
            transaction.update(docRef, { downloads: downloads });

            return Promise.resolve(downloads);
        })
    })
})