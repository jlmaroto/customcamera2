var CustomCamera2 = {
	getPicture: function(success, failure){
		cordova.exec(success, failure, "CustomCamera2", "openCamera", []);
	}
};
module.exports = CustomCamera2;
