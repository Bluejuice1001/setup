// Extract the mapchi-key parameter from the URL
const urlParams = new URLSearchParams(window.location.search);
const mapchiKey = urlParams.get('mapchi-key');

if (!mapchiKey) {
    console.error('Error: mapchi-key parameter is missing in the URL.');
} else {
    // Use the mapchi-key to fetch the required resources and load them dynamically
    fetch(`https://api.mapchi.com/accounts/latest-version-iframe.txt`)
        .then(response => response.text())
        .then(version => {
            const widgetURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-iframe@${version}/index.js`;
            const vendorURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-iframe@${version}/vendor.js`;
            const cssURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-iframe@${version}/index.css`;

            // Load the widget script dynamically
            const script = document.createElement('script');
            script.type = "module";
            script.setAttribute("mapchi-key", mapchiKey);
            script.setAttribute("crossorigin", "");            
            script.src = `${widgetURL}`;
            document.body.appendChild(script);

            // Optionally preload the vendor modules
            const preloadLink = document.createElement('link');
            preloadLink.rel = "modulepreload";
            preloadLink.href = vendorURL;
            document.head.appendChild(preloadLink);

            // Load the widget CSS dynamically
            const styleLink = document.createElement('link');
            styleLink.rel = "stylesheet";
            styleLink.href = cssURL;
            document.head.appendChild(styleLink);
        })
        .catch(error => {
            console.error('Error fetching resources:', error);
        });
}


