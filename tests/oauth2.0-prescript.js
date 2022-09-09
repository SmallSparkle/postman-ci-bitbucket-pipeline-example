// Data to identify that a request came from to see on monitoring system 
pm.request.headers.add("User-Agent: Any data what you want");

// Refresh the OAuth token if necessary
var tokenDate = new Date(2010, 1, 1);
var tokenTimestamp = pm.environment.get("OAuth_Timestamp");
if (tokenTimestamp) {
    tokenDate = Date.parse(tokenTimestamp);
}
var expiresInTime = pm.environment.get("ExpiresInTime");
if (!expiresInTime) {
    expiresInTime = 3600; // Set default expiration time to 5 minutes
}

if ((new Date() - tokenDate) >= expiresInTime) {
    var baseAuth = pm.environment.get("clientId") + ":" + pm.environment.get("clientSecret");
    var incodedBaseAuth = 'Basic ' + CryptoJS.enc.Base64.stringify(CryptoJS.enc.Utf8.parse(baseAuth));
    pm.sendRequest({
        url: pm.environment.get("accessTokenUrl"),
        method: 'POST',
        header: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': incodedBaseAuth,
        },
        body: {
            mode: 'urlencoded',
            urlencoded: [
                {key: "grant_type", value: "client_credentials", disabled: false},
            ]
        }
    }, function (err, res) {
        if (res.code > 200) {
            throw new Error("cant't get the token");            
        }

        pm.environment.set("OAuth_Token", res.json().access_token);
        pm.environment.set("OAuth_Timestamp", new Date());

        // Set the ExpiresInTime variable to the time given in the response if it exists
        if (res.json().expires_in) {
            expiresInTime = res.json().expires_in * 1000;
        }
        pm.environment.set("ExpiresInTime", expiresInTime);
    });
}