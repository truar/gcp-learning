# Lab : Baseline infrastructure

## Task 1 : Create a bucket
Easy step, just a simple command to create a bucket with the default value
```
gsutil mb gs://kraken-bucket01/
```

## Task 2 : Create a Pub/Sub topic
Create a Pub/Sub topic. Easy as well
```
gcloud pubsub topics create kraken-topic
```

## Task 3 : Create a Cloud Functions

```
mkdir gcf-thumbnail
cd gcf-thumbnail
```

> Create the file index.json
```
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const gcs = require("@google-cloud/storage")();
const PubSub = require("@google-cloud/pubsub");
const imagemagick = require("imagemagick-stream");

exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "kraken-topic";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });

          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
};
```

> Create the file package.json
```
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/storage": "1.5.1",
    "@google-cloud/pubsub": "^0.18.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
```

Create a Cloud Functions to execute the above code. It is triggered when a file is uploaded into the bucket.
You don't need to specify the location of the index.js and package.json file. But you need to be in their folder when
you execute the `gcloud functions deploy` command.
```
gcloud functions deploy kraken-function \
    --runtime nodejs8 \
    --trigger-resource kraken-bucket01 \
    --trigger-event google.storage.object.finalize \
    --entry-point=thumbnail \
    --allow-unauthenticated
```

Upload a JPG file into the bucket to trigger the `kraken-function`
```
cd ..
wget --output-document map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg
gsutil cp map.jpg gs://kraken-bucket01/
```

## Task 4 : Delete an unwanted user
* Access the IAM & ADMIN > IAM
* Filter by the username
* Edit and remove all roles
* Takes few seconds to update

# Personal feedback
* Not a really interesting labs. Very straightforward. I was done in 10 minutes instead of 60 minutes.
* Cloud functions are interesting, but limited to node js code
* I'd like to see how to use the Pub/Sub with a cluster of App engines. See if I can use it the same way as Kafka
