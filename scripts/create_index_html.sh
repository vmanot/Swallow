#!/bin/bash
create_index_html() {
    echo '<!DOCTYPE html>
<html>
<head>
    <title>Documentation</title>
    <link href="../css/index.3a335429.css" rel="stylesheet">
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto;
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .module-list {
            display: grid;
            gap: 20px;
            padding: 0;
        }
        .module-card {
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 20px;
            list-style: none;
            transition: all 0.2s;
        }
        .module-card:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        a { 
            color: #0066cc;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <h1>Swallow Documentation</h1>
    <ul class="module-list">' > "${INDEX_HTML_PATH}"
    
    for target in "${TARGETS[@]}"; do
        echo "        <li class=\"module-card\"><a href=\"${target}/\">${target}</a></li>" >> "${INDEX_HTML_PATH}"
    done
    
    echo "    </ul>
</body>
</html>" >> "${INDEX_HTML_PATH}"
}
create_index_html