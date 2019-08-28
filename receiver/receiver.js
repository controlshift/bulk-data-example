let https = require('https');
let AWS = require('aws-sdk');
'use strict';

let targetBucket = process.env.S3_BUCKET, // receiver bucket name
  s3 = new AWS.S3();

function processCsv(downloadUrl, table) {
    console.log("Processing: " + downloadUrl);
    copyToS3(downloadUrl, table +'.csv', function(res){
        console.log(res);
        sendResponse({"status": "processed"})
    });
}

function copyToS3(url, key, callback) {
    https.get(url, function onResponse(res) {
        if (res.statusCode >= 300) {
            return callback(new Error('error ' + res.statusCode + ' retrieving ' + url));
        }
        s3.upload({Bucket: targetBucket, Key: key, Body: res}, callback);
    })
      .on('error', function onError(err) {
          return callback(err);
      });
}

function sendResponse(body) {
    let response =  {
        isBase64Encoded: false,
        statusCode: 200,
        headers: {'Content-Type': 'application/json', 'x-controlshift-processed': '1'},
        body: JSON.stringify(body)
    };
    console.log("response: " + JSON.stringify(response));
    return response;
}

// Lambda event Handler
exports.handler = async (event) => {
    let receivedJSON = JSON.parse(event.body);
    console.log('Received event:', receivedJSON);
    if(receivedJSON.type === 'data.full_table_exported'){
        await processCsv(receivedJSON.data.url, receivedJSON.data.table);
    } else {
        return sendResponse({"status": "skipped", "payload": receivedJSON});
    }
};
