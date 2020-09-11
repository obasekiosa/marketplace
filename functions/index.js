const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
.document("/followers/{userId}/userFollowers/{followerId}")
.onCreate(async (snapshot, context) => {
    console.log("Follower created", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    //create followed users posts reference
    const followedUsersPostRef = admin
        .firestore()
        .collection('posts')
        .doc(userId)
        .collection('userPosts');

    // create the following user's timeline reference
    const timelinePostRef = admin
        .firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts');

    // get the followed user's posts
    const querySnapShot = await followedUsersPostRef.get();

    // add each users post to the following user's timeline
    querySnapShot.forEach(doc => {
        if (doc.exists) {
            const postId = doc.id;
            const postData = doc.data();
            timelinePostRef.doc(postId).set(postData);
        }
    });
});
