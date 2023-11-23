fetch('https://api.mapchi.com/accounts/latest-version.txt')
 .then(response => response.text())
 .then(version => {
     console.log(version);
     const widgetURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-widget@${version}/index.js`;
     console.log(widgetURL);
     const vendorURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-widget@${version}/vendor.js`;
     console.log(vendorURL);
     const cssURL = `https://cdn.jsdelivr.net/gh/Bluejuice1001/mapche-search-widget@${version}/index.css`;
     console.log(cssURL);

     // Fetch the current script tag to get the mapchi-key attribute
     const currentScript = [...document.scripts].filter(script => script.src.includes("loader.js"))[0];
     const mapchiKey = currentScript ? currentScript.getAttribute('mapchi-key') : null;
//     const mapchiKey = '93e40f61-60ab-4516-a5e2-7dd14d579206';
     
     if (!mapchiKey) {
         console.error('Error: mapchi-key attribute is missing in the script tag.');
         return;
     }

     // Load the widget script dynamically
     const script = document.createElement('script');
     script.type = "module";
     script.setAttribute("mapchi-key", mapchiKey);
     script.setAttribute("crossorigin", "");
     script.src = widgetURL;
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
 });

