const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.user_login = functions.auth.user().onCreate((user, context) => {
    let uid = user.uid;
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
    let db = admin.database();
    let ref = db.ref('users/' + uid);
    return ref.set({
        'name': name,
    }).then(() => {
        return 0;
    }).catch((error) => {
        console.error('FUNCTIONS - user_login ERROR (writing to database):')
        console.error(error)
    });
});
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

exports.downloads_changed = functions.database.ref('pack_download_counts/{pack_id}').onWrite((snapshot, context) => {
    const packID = context.params.pack_id;
    const downloadCount = snapshot.after.val();
    
    const db = admin.database();
    const packRef = db.ref('sticker_packs/' + packID + '/downloads');
    return packRef.set(downloadCount).then(() => {
        return 0;
    }).catch((error) => {
        console.error('FUNCTIONS - downloads_changed ERROR (writing to database):');
        console.error(error);
    });
});