const fs = require('fs');
const geoip = require('geoip-lite');

var USE_IP2 = false;

if (fs.existsSync("./IP2LOCATION-LITE-DB1.BIN")) {
	USE_IP2 = true;
	const {IP2Location} = require("ip2location-nodejs");
	const ip2location = new IP2Location();
	
	ip2location.open("./IP2LOCATION-LITE-DB1.BIN");
}

var inputFile = process.argv[2];

const contents = fs.readFileSync(inputFile, 'utf-8')
const arr = contents.split(/\r?\n/)

const regex = new RegExp('((?<![^\\/]\\/)\\b\\w+\\.\\b\\w{2,3}(?:\\.\\b\\w{2})?)(?:$|\\/)', 'gm')

arr.forEach( (info, idx )=> {

	info = info.split(' ');
	if (info.length<2) return;

    let dom = regex.exec(info[1]);
	let IP  = info[0];

    if (!dom || dom.length<0) return;

    let geo = geoip.lookup(IP);

	
	var ip2 = '';
	if (USE_IP2) {
  		    ip2 = ip2location.getCountryShort(IP)
			if (ip2=='-') ip2 = '';
	}

    if (geo && geo.country) {
        console.log(`${geo.country} ${dom[1]} ${IP}`);
		if (ip2 && ip2.length>0 && ip2!=geo.country) {
			console.log(`${ip2} ${dom[1]} ${IP}`);	
		}
    } else if (ip2 && ip2.length>0) {
		console.log(`${ip2} ${dom[1]} ${IP}`);
    } else {
		console.log(`?? ${dom[1]} ${IP}`);
	}

})

if (USE_IP2) {
	ip2location.close();
}
