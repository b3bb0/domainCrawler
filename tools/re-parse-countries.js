const { execSync } = require('child_process');
const fs = require('fs');

const {IP2Location} = require("ip2location-nodejs");

let ip2location = new IP2Location();

ip2location.open("./IP2LOCATION-LITE-DB1.BIN")

var inputFile = process.argv[2];

const contents = fs.readFileSync(inputFile, 'utf-8')
const arr = contents.split(/\r?\n/)


arr.forEach( (info, idx )=> {

	const d = info.split(' ');

	let n = ip2location.getCountryShort(d[2])

	if (n!=d[0]) {
		console.log(`${n} ${d[1]} ${d[2]}`)
	}

})


ip2location.close();
