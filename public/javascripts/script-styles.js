(function () {
	var head = document.getElementsByTagName("head")[0];
	if (head) {
		var scriptStyles = document.createElement("link");
		scriptStyles.rel = "stylesheet";
		scriptStyles.type = "text/css";
		scriptStyles.href = "/stylesheets/script-styles.css";
		head.appendChild(scriptStyles);
	}
}());
