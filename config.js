require('dotenv').config()

function getBoolean(str) {
	if(str) {
		if(str.toUpperCase()=='TRUE') {
			return true;
		} else if(str.toUpperCase()=='FALSE') {
			return false;
		} else {
			return str;
		}
	} else {
		return false;
	}
}

module.exports = {
    DBHOST: process.env.DBHOST,
    DBUSER: process.env.DBUSER,
    DBPASS: process.env.DBPASS,
    DBNAME: process.env.DBNAME,
    DBPORT: process.env.DBPORT || 3306,
    DBSSL: getBoolean(process.env.DBSSL) || false,
    LISTENPORT: parseInt(process.env.LISTENPORT) || 3000
}