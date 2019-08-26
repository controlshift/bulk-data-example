var https = require('https');
var url = require('url');
var AWS = require('aws-sdk');

function csvReceiver(downloadUrl, eventContext, webhookJSON){
    var targetBucket = process.env.S3_BUCKET, // receiver bucket name
        s3 = new AWS.S3(),
        firstLineRemoved = false,
        csvData = '',
        context = eventContext,
        receivedJSON = webhookJSON;

    var parseFileName = function(url_string){
        path = url.parse(url_string).pathname
        return path.substr(path.lastIndexOf('/')+1)
    }

    // Remove Headers
    var removeFirstLine = function(chunk){
        if(firstLineRemoved){
            csvData += chunk;
        }else{
            var buffer = chunk.toString();
            if (buffer.indexOf('\n') !== -1) {
                csvData += chunk.slice(chunk.indexOf('\n') + 1);
                firstLineRemoved = true;
                buffer = null;
            }
        }
    }

    var uploadCsv = function(){
        var upload_details = {Bucket: targetBucket, Key: fileName, Body: csvData};
        s3.upload(upload_details, function(err, data) {
            if (err){
                // an error occurred
                console.log(err, err.stack);
                context.fail(err);
            }else{
                // successful response
                context.succeed({"status": "success", "payload": receivedJSON});
            }
        });
    }

    return {
        processCsv: function(){
            fileName = parseFileName(downloadUrl);
            https.get(downloadUrl, function(httpResponse) {
                httpResponse.on('data', function(chunk) {
                    removeFirstLine(chunk);
                });
                httpResponse.on('end', function() {
                    console.log(httpResponse);
                    uploadCsv();
                });
            });
        }
    }
}

// Lambda event Handler
exports.handler = function(event, context) {
    var receivedJSON = JSON.stringify(event, null, 2);
    console.log('Received event:', receivedJSON);
    if(event.type === 'data.full_table_exported'){
        let receiver = new csvReceiver(event.data.url, context, receivedJSON);
        receiver.processCsv();
    }else{
        context.succeed({"status": "skipped", "payload": receivedJSON});
    }
};
